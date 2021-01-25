' ------------------------------------------------------------------------------
' -- src/managers/virtual_controller.bmx
' --
' -- Maps named virtual inputs to actual devices.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.linkedlist
Import brl.map
Import sodaware.ObjectBag

Import "base_controller_input.bmx"

Type VirtualController

	Field _actions:TMap
	Field _listeners:ObjectBag


	' ------------------------------------------------------------
	' -- Adding actions and inputs
	' ------------------------------------------------------------

	Method addAction(name:String)
		Self._actions.Insert(name, New TList)
	End Method

	Method addInput(name:String, listener:BaseControllerInput)
		Local a:TList = TList(Self._actions.ValueForKey(name))
		a.AddFirst(listener)
		Self._listeners.add(listener)
	End Method

	Method flush()
		For Local l:BaseControllerInput = EachIn Self._listeners
			l.flush()
		Next
	End Method

	Method action:Byte(name:String)
		Local a:TList = TList(Self._actions.ValueForKey(name))
		For Local l:BaseControllerInput = EachIn a
			If l.isDown() Return True
		Next

		Return False
	End Method

	Method down:Byte(name:String)
		Return Self.action(name)
	End Method

	Method hit:Byte(name:String)
		Local a:TList = TList(Self._actions.ValueForKey(name))
		For Local l:BaseControllerInput = EachIn a
			If l.isPressed() Return True
		Next

		Return False
	End Method

	Method up:Byte(name:String)
		Local a:TList = TList(Self._actions.ValueForKey(name))
		For Local l:BaseControllerInput = EachIn a
			If l.isUp() Return True
		Next

		Return False
	End Method

	Method released:Byte(name:String)
		Local a:TList = TList(Self._actions.ValueForKey(name))
		For Local l:BaseControllerInput = EachIn a
			If l.isReleased() Return True
		Next

		Return False
	End Method

	Method downtime:Float(name:String)
		Local a:TList = TList(Self._actions.ValueForKey(name))
		For Local l:BaseControllerInput = EachIn a
			If l.getDownTime() > 0 Then Return l.getDownTime()
		Next

		Return 0
	End Method

	Method lastDowntime:Float(name:String)
		Local a:TList = TList(Self._actions.ValueForKey(name))
		For Local l:BaseControllerInput = EachIn a
			If l.getLastDowntime() > 0 Then Return l.getLastDowntime()
		Next

		Return 0
	End Method

	Method update(delta:Float)
		For Local listener:BaseControllerInput = EachIn Self._listeners
			' TODO: This works with `_inputUp` commented out - why?
			listener._inputUp()
			listener._inputDown()
			listener.update(delta)
		Next
	End Method

	Method New()
		Self._actions = New TMap
		Self._listeners = New ObjectBag
	End Method

End Type
