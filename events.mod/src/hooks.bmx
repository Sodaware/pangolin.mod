' ------------------------------------------------------------------------------
' -- src/hooks.bmx
' --
' -- Generic hook container. Supports named hooks.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.map

Import sodaware.StringList

Import "event_handler_bag.bmx"

Type Hooks

	Field _strictMode:Byte         = True
	Field _hooks:TMap              = New TMap
	Field _allowedHooks:StringList = New StringList


	' ------------------------------------------------------------
	' -- Executing Hooks
	' ------------------------------------------------------------

	''' <summary>Run a hook. Sends the event to all registered callbacks.</summary>
	''' <param name="name">The name of the hook to run.</param>
	''' <param name="event">The GameEvent to send to all callbacks.</param>
	Method runHook(name:String, event:GameEvent)
		Local handlers:EventHandlerBag = Self.getHook(name)
		handlers.runAll(event)
	End Method

	''' <summary>Run all hooks for an event. Uses the event's name to find hooks.</summary>
	''' <param name="event">The GameEvent to run hooks with.</param>
	Method sendEvent(event:GameEvent)
		Self.runHook(event.name, event)
	End Method


	' ------------------------------------------------------------
	' -- Registering Hooks
	' ------------------------------------------------------------

	''' <summary>
	''' Register a hook name. Hook names must be registered before callbacks
	''' are added when strict mode is enabled.
	''' </summary>
	''' <param name="name">The name of the hook to register.</param>
	Method registerHook:Hooks(name:String)
		If Not Self.isHookRegistered(name) Then
			Self._allowedHooks.addLast(name)
			Self.getHook(name)
		EndIf
		Return Self
	End Method

	''' <summary>
	''' Register a list of hook names. Hook names must be registered before
	''' callbacks are added when strict mode is enabled.
	''' </summary>
	''' <param name="name">The name of the hook to register.</param>
	Method registerHooks:Hooks(hookNames:String[])
		If hookNames And hookNames.Length Then
			For Local name:String = EachIn hookNames
				Self.registerHook(name)
			Next
		End If
		Return Self
	End Method

	''' <summary>Check if a hook name has been registered.</summary>
	''' <param name="name">The name of the hook to check.</param>
	''' <return>True if hook registered, false if not.</return>
	Method isHookRegistered:Byte(name:String)
		Return Self._allowedHooks.contains(name)
	End Method


	' ------------------------------------------------------------
	' -- Adding and removing hooks
	' ------------------------------------------------------------

	''' <summary>Add a callback to a hook.</summary>
	''' <param name="name">The name of the hook to register a callback for.</param>
	''' <param name="handler">Valid event handler that will be called when hook executes.</param>
	Method add:Hooks(name:String, handler:EventHandler)
		If Self._strictMode Then Self.validateHookName(name)

		Local handlers:EventHandlerBag = Self.getHook(name)
		handlers.add(handler)
		Return Self
	End Method

	Method clearHooks(name:String)
		Local handlers:EventHandlerBag = Self.getHook(name)
		handlers.clear()
	End Method

	Method getHook:EventHandlerBag(name:String)
		Local handlers:EventHandlerBag = EventHandlerBag(Self._hooks.ValueForKey(name))

		If handlers = Null Then
			handlers = New EventHandlerBag
			Self._hooks.Insert(name, handlers)
		EndIf

		Return handlers
	End Method


	' ------------------------------------------------------------
	' -- Internal Validation
	' ------------------------------------------------------------

	Method validateHookName(name:String)
		If False = Self.isHookRegistered(name) Then
			Throw "Invalid hook name in `add`: ~q" + name + "~q"
		End If
	End Method


	' ------------------------------------------------------------
	' -- Construction
	' ------------------------------------------------------------

	Function Create:Hooks(hookNames:String[])
		Local this:Hooks = New Hooks
		this.registerHooks(hookNames)
		Return this
	End Function

End Type
