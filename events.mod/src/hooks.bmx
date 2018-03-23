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

	Method runAll(name:String, event:GameEvent)
		Local handlers:EventHandlerBag = Self.getHook(name)
		handlers.runAll(event)
	End Method


	' ------------------------------------------------------------
	' -- Registering Hooks
	' ------------------------------------------------------------

	Method registerHook:Hooks(name:String)
		If Not Self.isHookRegistered(name) Then
			Self._allowedHooks.addLast(name)
			Self.getHook(name)
		EndIf
		Return Self
	End Method

	Method registerHooks:Hooks(hookNames:String[])
		If hookNames And hookNames.Length Then
			For Local name:String = EachIn hookNames
				Self.registerHook(name)
			Next
		End If
		Return Self
	End Method

	Method isHookRegistered:Byte(name:String)
		Return Self._allowedHooks.contains(name)
	End Method

	Method validHook:Byte(name:String)
		Return Self._allowedHooks.contains(name)
	End Method


	' ------------------------------------------------------------
	' -- Adding and removing hooks
	' ------------------------------------------------------------

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
		If Self.validHook(name) = False Then
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
