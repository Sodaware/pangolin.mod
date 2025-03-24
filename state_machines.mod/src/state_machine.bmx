' ------------------------------------------------------------------------------
' -- pangolin.state_machines - src/state_machine.bmx
' --
' -- Base type used for state machines.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2019 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.map
Import brl.linkedlist

Import pangolin.events
Import sodaware.stringlist

Include "exceptions.bmx"
Include "state_handler.bmx"
Include "state_transition.bmx"
Include "state_transition_handler.bmx"

''' <summary>
''' General purpose state machine.
'''
''' State machines are made up of a list of states and the allowed transitions
''' between them. They provide hooks for when states change, and they can use
''' `StateTransitionHandler` objects for more complex tasks.
'''
''' They also provide an `update` and `handleInput` method that can be called
''' from a game screen. This will call any assigned `StateHandler` instance for
''' the current state.
''' </summary>
Type StateMachine
	Field _state:String                 '''< The current state name.
	Field _previousState:String         '''< The previous state name.
	Field _isTransitioning:Byte         '''< Is the state machine currently transitioning?
	Field _transition:StateTransition   '''< The current StateTransition instance.
	Field _handler:StateHandler         '''< The current StateHandler instance.

	Field _states:StringList            '''< List of registered state names.
	Field _stateHandlers:TMap           '''< Map of state name => StateHandler instances.
	Field _transitions:TMap             '''< Map of transition name => StateTransition instances.
	Field _transitionHandlers:TMap      '''< Map of transition name => StateTransitionHandler instances.
	Field _queue:StringList             '''< Queue of transitions to run.

	Field _locked:Byte                  '''< If true, no more state names can be added.
	Field _hooks:Hooks                  '''< Internal hooks.
	Field _attachedTo:Object            '''< The object (usually a screen or entity) this machine belongs to.


	' ------------------------------------------------------------
	' -- Hooks
	' ------------------------------------------------------------

	''' <summary>Hook for when a transition is started.</summary>
	Method whenTransitionStarted(handler:EventHandler)
		Self._hooks.add("transition_start", handler)
	End Method

	''' <summary>Hook for when a transition is finished.</summary>
	Method whenTransitionFinished(handler:EventHandler)
		Self._hooks.add("transition_end", handler)
	End Method

	''' <summary>
	''' Hook for when a state is entered.
	'''
	''' These run in addition to any StateTransitionHandler instances. They are
	''' executed first.
	''' </summary>
	''' <param name="state">The name of the entered state.</param>
	''' <param name="handler">The handler to run</param>
	Method whenStateEntered(state:String, handler:EventHandler)
		Self._hooks.add(state + ".enter", handler)
	End Method

	''' <summary>
	''' Hook for when a state is exited.
	'''
	''' These run in addition to any StateTransitionHandler instances. They are
	''' executed first.
	''' </summary>
	''' <param name="state">The name of the exited state.</param>
	''' <param name="handler">The handler to run</param>
	Method whenStateExited(state:String, handler:EventHandler)
		Self._hooks.add(state + ".exit", handler)
	End Method


	' ------------------------------------------------------------
	' -- Querying
	' ------------------------------------------------------------

	''' <summary>
	''' Get the name of the current state.
	'''
	''' May be blank.
	''' </summary>
	Method getCurrentStateName:String()
		Return Self._state
	End Method

	''' <summary>Get the object this StateMachine is attached to.</summary>
	Method getParent:Object()
		Return Self._attachedTo
	End Method

	''' <summary>Check if this StateMachine has a state defined.</summary>
	''' <param name="name">The name of the state to check for. Case sensitive.</param>
	''' <return>True if the state is defined, false if not.</return>
	Method hasState:Byte(name:String)
		Return Self._states.contains(name)
	End Method


	' ------------------------------------------------------------
	' -- Locking
	' ------------------------------------------------------------

	''' <summary>
	''' Mark the state machine as locked.
	'''
	''' Locking a state machine causes it to throw an exception if new states
	''' are added.
	''' </summary>
	Method lock()
		Self._locked = True
	End Method

	''' <summary>
	Method isLocked:Byte()
		Return Self._locked
	End Method

	Method checkLock()
		If Self.isLocked() Then
			Throw New LockedStateMachineException
		EndIf
	End Method

	
	' ------------------------------------------------------------
	' -- Configuring States
	' ------------------------------------------------------------

	Method addState:StateMachine(name:String)
		Self.checkLock()

		If name <> "" Then Self._states.add(name)

		Return Self
	End Method

	Method addStates:StateMachine(names:String[])
		Self.checkLock()

		For Local name:String = EachIn names
			Self.addState(name)
		Next

		Return Self
	End Method

	Method ensureStateExists(name:String)
		If Self._states.contains(name) Then Return

		Throw MissingStateException.Create(name)
	End Method

	''' <summary>
	''' Set the current state without running any transitions or handlers.
	'''
	''' This can only when the current state is blank (i.e. no transitions have
	''' been run).
	''' </summary>
	''' <param name="name">The state to set.</param>
	''' <return>StateMachine instance.</return>
	Method setInitialState:StateMachine(name:String)
		' TODO: Maybe return an exception here?
		If Self._state <> "" Then Return Self
		
		Self.ensureStateExists(name)

		Self._state = name

		Return Self
	End Method


	''' <summary>Add a state handler.</summary>
	Method addStateHandler(name:String, handler:StateHandler)
		If Self._locked Then Self.ensureStateExists(name)

		If Self._stateHandlers.valueForKey(name) <> Null Then
			Throw StateHandlerAlreadyRegisteredException.Create(name)
		EndIf

		' Set the parent/target properly.
		handler._target = Self._attachedTo
		handler._parent = Self

		' Initialize the handler.
		handler.initialize()

		Self._stateHandlers.Insert(name, handler)
	End Method


	' ------------------------------------------------------------
	' -- Adding Transitions
	' ------------------------------------------------------------

	''' <summary>
	''' Add a transition to the state machine.
	'''
	''' A transition is a named change from one state to another. A transition
	''' can have multiple "from" states, but only one target state.
	''' </summary>
	''' <param name="name">The name of the state transition.</param>
	''' <param name="fromState">The state this can be entered from. Pass Null if this is an inital transition.</param>
	''' <param name="toState">Optional state this can be transitioned to.</param>
	Method addTransition(name:String, fromState:String, toState:String = "")
		' TODO: Eventually should be able to pass array of strings as `fromState`
		If Self.getTransition(name) Then
			Self.addTransitionFrom(name, fromState)

			Return
		EndIf

		Local t:StateTransition = StateTransition.Create(name, fromState, toState)

		' Add hooks for entering and leaving both states.
		Self._hooks.registerHook(fromState + ".enter")
		Self._hooks.registerHook(fromState + ".exit")

		' Add the transition and create handlers list.
		Self._transitions.Insert(name, t)
		Self._transitionHandlers.Insert(name, New TList)
	End Method

	''' <summary>Add an additional start state for a transition.</summary>
	''' <param name="name">The transition to modify.</param>
	''' <param name="fromState">A state this transition can start from.</param>
	Method addTransitionFrom(name:String, fromState:String)
		' Search for the existing transition.
		Local t:StateTransition = Self.getTransition(name)
		If t = Null Then Throw MissingStateTransitionException.Create(name)

		' Check state exists.
		If Self._locked Then Self.ensureStateExists(fromState)

		' Do nothing if the state already has this target.
		If t.canTransitionFrom(fromState) Then Return

		' Add the state.
		t.addFromState(fromState)

		' Add hooks for entering and leaving both states.
		Self._hooks.registerHook(fromState + ".enter")
		Self._hooks.registerHook(fromState + ".exit")
	End Method

	''' <summary>Add a custom handler for a transition.</summary>
	''' <param name="transition">The transition to add a handler for.</param>
	''' <param name="handler">The handler instance.</param>
	Method addTransitionHandler(transition:String, handler:StateTransitionHandler)
		Local handlers:TList = TList(Self._transitionHandlers.valueforkey(transition))
		If handlers = Null Then Throw MissingStateTransitionException.Create(transition)

		' Set the parent manager and target for this state handler.
		handler._target = Self._attachedTo
		handler._parent = Self

		' Initialize the handler.
		handler.initialize()
		
		' Add to the list of handlers.
		handlers.addLast(handler)
	End Method

	''' <summary>Run a transition after the current transition finishes.</summary>
	''' <param name="nextTransition">The transition to run.</param>
	Method andThen(nextTransition:String)
		Self._queue.AddLast(nextTransition)
	End Method


	' ------------------------------------------------------------
	' -- Transition Helpers
	' ------------------------------------------------------------

	''' <summary>Run a transition.</summary>
	''' <exception cref="MissingStateTransitionException">Thrown if transition name does not exist in the state machine.</exception>
	''' <exception cref="InvalidTransitionForStateException">Thrown if the current state cannot run this transition.</exception>
	''' <param name="name">The name of the state to run.</param>
	''' <return>The StateMachine instance.</return>
	Method transition:StateMachine(name:String)
		Local t:StateTransition = StateTransition(Self._transitions.ValueForKey(name))
		If t = Null Then Throw MissingStateTransitionException.Create(name)

		If Not Self.canTransition(name) Then
			Throw InvalidTransitionForStateException.Create(name, Self._state)
		End If

		' Run the transition.
		Self._isTransitioning = True

		' Run "onExit" handlers and hooks.
		If Self._handler Then Self._handler.onExit()
		Self.onStateExited(Self._state, t)

		' Set the current state to null until the transition is done.
		Self._previousState = Self._state
		Self._state         = Null
		Self._handler       = Null

		Self._transition = t
		Self.onTransitionStarted(t)
		Self._transition.start()

		' Run the transition.
		Self._runTransitionHandlers(t)

		Return Self
	End Method

	Method isTransitioning:Byte()
		Return Self._isTransitioning
	End Method

	Method canTransition:Byte(name:String)
		Local t:StateTransition = StateTransition(Self._transitions.ValueForKey(name))

		Return t.canTransitionFrom(Self._state)
	End Method

	Method canTransitionTo:Byte(state:String)
		' TODO: Get transitions where current state is from.
		' TODO: If the `to` state is `t`, return true. otherwise false.
	End Method


	' ------------------------------------------------------------
	' -- State Processing
	' ------------------------------------------------------------

	Method update(delta:Float, noFocus:Byte = False, covered:Byte = False)
		' Do nothing if no transition or state is selected.
		If Self._transition = Null And Self._handler = Null Then Return

		' Run the current state and return. Transitions should not be running at
		' the same time.
		If Self._transition = Null And Self._handler Then
			Self._handler.update(delta, noFocus, covered)

			Return
		EndIf

		' Update the current transitions.
		If Self._transition Then
			Local handlers:TList = TList(Self._transitionHandlers.valueforkey(Self._transition.name))
			If handlers Then
				For Local handler:StateTransitionHandler = EachIn handlers
					handler.update(delta, noFocus, covered)
				Next
			EndIf
		EndIf

		' Move the the next state if all handlers have finished.
		If Self._allHandlersFinished() Then
			Self._isTransitioning = False

			Self._previousState = Self._state
			Self._state         = Self._transition._To
			Self._handler       = StateHandler(Self._stateHandlers.valueForKey(Self._state))

			If Self._handler Then Self._handler.onEnter()

			Self.onTransitionFinished(Self._transition)
			Self._transition = Null

			Self.onStateEntered(Self._state, Self._transition)

			DebugLog "The new state is: " + Self._state

			' Move to next one if needed.
			If Not Self._queue.IsEmpty() Then
				Local transitionTo:String = String(Self._queue.RemoveFirst())
				DebugLog "Removed item from queue: " + transitionTo
				Self.transition(transitionTo)
			End If
		End If
	End Method

	Method handleInput()
		If Self._handler Then Self._handler.handleInput()
	End Method


	' ------------------------------------------------------------
	' -- Auto-loading
	' ------------------------------------------------------------

	''' <summary>
	''' Autoload all state handlers and transition handlers for this machine.
	'''
	''' By default, will recursively scane state and transition handlers for any
	''' derived from the base type. It's faster to pass in base transition and
	''' state handlers that are related to the machine, but not required.
	''' </summary>
	Method autoload(tag:String, transitionType:String = "", handlerType:String = "")
		DebugLog "Autoloading state handlers"
		Self.autoloadStates(tag, handlerType)

		DebugLog "Autoloading transition handlers"
		Self.autoloadTransitions(tag, transitionType)
	End Method

	Method autoloadStates(tag:String, baseType:String = "")
		If tag = "" Then Throw New EmptyAutoloadTagException
		If baseType = "" Then baseType = "StateHandler"

		' Get all transition handlers.
		Local baseHandler:TTypeId = TTypeId.forName(baseType)
		For Local handler:TTypeId = EachIn baseHandler.derivedTypes()
			' Autoload if tags match.
			If handler.metaData("tag") = tag Then
				DebugLog "  - Loaded state handler " + handler.metaData("state_name") + " => " + handler.name()
				Self.addStateHandler(handler.metaData("state_name"), StateHandler(handler.NewObject()))
			EndIf

			' Add any derived types.
			Self.autoloadStates(tag, handler.name())
		Next
	End Method

	''' <summary>
	''' Autoload transition handlers.
	'''
	''' Scans the runtime for Types that extend `StateTransitionHandler`. If
	''' they have a tag that matches TAG then they will be added as a transition
	''' handler for this state machine.
	''' </summary>
	''' <param name="tag">The tag to search for.</param>
	''' <param name="baseType">
	''' If this is present, the autoloader will search for types that extend it
	''' instead of `StateTransitionHandler`.
	''' </param>
	Method autoloadTransitions(tag:String, baseType:String = "")
		If tag = "" Then Throw New EmptyAutoloadTagException
		If baseType = "" Then baseType = "StateTransitionHandler"

		' Get all transition handlers.
		Local baseHandler:TTypeId = TTypeId.forName(baseType)
		For Local handler:TTypeId = EachIn baseHandler.derivedTypes()
			' Autoload if tags match.
			If handler.metaData("tag") = tag Then
				' Register the item.
				DebugLog "TAG: " + tag + " => " + handler.metaData("tag")
				DebugLog "  - Loaded transition handler " + handler.metaData("transition_name") + " => " + handler.name()
				Self.addTransitionHandler(handler.metaData("transition_name"), StateTransitionHandler(handler.NewObject()))
			EndIf

			' Add any derived types.
			Self.autoloadTransitions(tag, handler.name())
		Next
	End Method


	' ------------------------------------------------------------
	' -- Internal Processing
	' ------------------------------------------------------------

	Method _allHandlersFinished:Byte()
		Local handlers:TList = TList(Self._transitionHandlers.ValueForKey(Self._transition.name))
		For Local handler:StateTransitionHandler = EachIn handlers
			If Not handler.isFinished() Then Return False
		Next

		Return True
	End Method

	Method _runTransitionHandlers(t:StateTransition)
		' Run each transition handler.
		Local handlers:TList = TList(Self._transitionHandlers.ValueForKey(t.name))
		If handlers = Null Or handlers.IsEmpty() Then Return

		' Run each handler.
		For Local handler:StateTransitionHandler = EachIn handlers
			handler.reset()
			handler.start()
		Next
	End Method

	Method onTransitionStarted(t:StateTransition)
		' TODO: Run hook here
	End Method

	Method onTransitionFinished(t:StateTransition)
		' TODO: Run hook here
	End Method

	Method onStateEntered(state:String, t:StateTransition)
		Local e:GameEvent = New GameEvent

		Self._hooks.runHook(state + ".enter", e)
	End Method

	Method onStateExited(state:String, t:StateTransition)
		Local e:GameEvent = New GameEvent

		Self._hooks.runHook(state + ".exit", e)
	End Method

	Method findOrCreateTransition:StateTransition(name:String)
		Local t:StateTransition = StateTransition(Self._transitions.ValueForKey(name))
		If t = Null Then t = StateTransition.Create(name)

		Return t
	End Method

	Method getTransition:StateTransition(name:String)
		Return StateTransition(Self._transitions.ValueForKey(name))
	End Method


	' ------------------------------------------------------------
	' -- Creation
	' ------------------------------------------------------------

	''' <summary>Create a new state machine and attach it to an object.</summary>
	''' <param name="parent">The object to attach it to.</param>
	Function Create:StateMachine(parent:Object)
		Local this:StateMachine = New StateMachine

		this._attachedTo = parent

		Return this
	End Function

	Method New()
		Self._hooks              = Hooks.Create(["transition_start", "transition_end"])
		Self._stateHandlers      = New TMap
		Self._transitions        = New TMap
		Self._transitionHandlers = New TMap
		Self._queue              = New StringList
		Self._states             = New StringList
	End Method
End Type
