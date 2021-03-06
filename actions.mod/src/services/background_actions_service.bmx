' ------------------------------------------------------------------------------
' -- src/services/background_actions_service.bmx
' --
' -- Service for updating and managing background actions.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.core
Import brl.linkedlist

Import "../core/background_action.bmx"
Import "../core/action_queue.bmx"

Type BackgroundActionsService Extends GameService ..
	{ implements = "update" }

	' Services.
	Field _kernelInformation:KernelInformationService		{ injectable }

	' Internals
	Field _actionList:TList                                 '''< A list of actions that will execute in parallel.
	Field _actionCount:Int                                  '''< Cached number of queued actions.
	Field _toStart:TList                                    '''< List of actions to start.
	Field _toStartCount:Int                                 '''< Cached number of actions to start.
	Field _hooks:Hooks                                      '''< Action hooks.


	' ------------------------------------------------------------
	' -- Hooks
	' ------------------------------------------------------------

	''' <summary>Execute a callback when an action is added.</summary>
	Method whenActionAdded(callback:EventHandler)
		Self._hooks.add("action_added", callback)
	End Method

	''' <summary>Execute a callback when an action is started.</summary>
	Method whenActionStarted(callback:EventHandler)
		Self._hooks.add("action_started", callback)
	End Method

	''' <summary>Execute a callback when an action has finished.</summary>
	Method whenActionFinished(callback:EventHandler)
		Self._hooks.add("action_finished", callback)
	End Method


	' ------------------------------------------------------------
	' -- Adding Items
	' ------------------------------------------------------------

	''' <summary>
	''' Pushes a background action onto the list of executing actions.
	'''
	''' All actions are executed in parallel, but can be executed serially by
	''' adding them to an `ActionQueue`.
	''' </summary>
	''' <param name="action">The action to push</param>
	''' <return>The action that was pushed.</return>
	Method pushAction:BackgroundAction(action:BackgroundAction)

		' Inject the game kernel into the action and autoload.
		action.setKernel(Self._kernelInformation.getKernel())
		action.autoloadServices()

		' Initialize the background action.
		action.init()

		' Mark the action as startable.
		Self._toStart.AddLast(action)
		Self._toStartCount :+ 1

		' Add action to the queue
		Self._actionList.AddLast(action)
		Self._actionCount:+ 1

		' Notify any callbacks.
		Self._hooks.sendEvent(GameEvent.CreateSimple("action_added", action))

		Return action

	End Method


	' ------------------------------------------------------------
	' -- Creation Helpers
	' ------------------------------------------------------------

	''' <summary>
	''' Create and return an ActionQueue instance.
	'''
	''' Sets up the kernel so that information can be autoloaded by child
	''' actions.
	''' </summary>
	Method createQueue:ActionQueue()
		Local queue:ActionQueue = New ActionQueue

		queue.setKernel(Self._kernelInformation.getKernel())

		Return queue
	End Method


	' ------------------------------------------------------------
	' -- Action Execution
	' ------------------------------------------------------------

	''' <summary>
	''' Called every frame. Runs all actions and removes any finished actions
	''' from the list.
	''' </summary>
	Method update(delta:Float)

		' Do nothing if no actions in the queue.
		If Self._actionCount = 0 Then Return

		' Start any services that need it.
		If Self._toStartCount Then
			For Local action:BackgroundAction = EachIn Self._toStart
				action.onStart()

				Self._hooks.sendEvent(GameEvent.CreateSimple("action_started", action))
			Next

			Self._toStart.Clear()
			Self._toStartCount = 0
		EndIf

		' Execute each action.
		For Local action:BackgroundAction = EachIn Self._actionList

			' Run action.
			action.execute(delta)

			' Remove if finished.
			If action.isFinished() Then

				' Send hooks.
				Self._hooks.sendEvent(GameEvent.CreateSimple("action_finished", action))

				' Allow the action to run any cleanup.
				action.onFinish()

				' Remove from the list and destroy the action.
				Self._actionList.remove(action)
				Self._actionCount :- 1

				action = Null

			EndIf

		Next

	End Method

	Method clear()
		Self._actionList.clear()
		Self._actionCount = 0
	End Method


	' ------------------------------------------------------------
	' -- Construction / Destruction
	' ------------------------------------------------------------

	Method New()
		Self.init()

		Self._actionList  = New TList
		Self._actionCount = 0
		Self._toStart     = New TList
		Self._hooks       = New Hooks

		Self._hooks.registerHook("action_added")
		Self._hooks.registerHook("action_started")
		Self._hooks.registerHook("action_finished")
	End Method

End Type
