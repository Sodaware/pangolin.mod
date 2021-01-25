' ------------------------------------------------------------------------------
' -- src/controllers/base_controller_input.bmx
' --
' -- Base input that physical controller drivers must extend.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------

SuperStrict

Type BaseControllerInput Abstract

	Field _isDown:Byte
	Field _isPressed:Byte
	Field _isReleased:Byte
	Field _downTime:Float = -1
	Field _upTime:Float   = -1
	Field _lastTime:Float


	' ------------------------------------------------------------
	' -- Private overide methods
	' ------------------------------------------------------------

	Method _inputDown() Abstract
	Method _inputUp() Abstract


	' ------------------------------------------------------------
	' -- Querying
	' ------------------------------------------------------------

	Method getUpTime:Float() Final
		Return Self._upTime
	End Method

	Method getDownTime:Float() Final
		Return Self._downTime
	End Method

	Method isReleased:Byte() Final
		Return Self._isReleased
	End Method

	Method isPressed:Byte() Final
		Return Self._isPressed
	End Method

	Method isDown:Byte() Final
		Return Self._isDown
	End Method

	Method isUp:Byte() Final
		Return Not(Self._isDown)
	End Method

	Method getLastDowntime:Float() Final
		Return Self._lastTime
	End Method


	' ------------------------------------------------------------
	' -- Standard Updating
	' ------------------------------------------------------------

	Method update(delta:Float)
		If Self._isDown Then
			Self._isPressed  = (Self._downTime = 0)
			Self._isReleased = False
			Self._downTime :+  delta
			Self._upTime     = Self._upTime
			Self._upTime	 = 0
		Else
			Self._isReleased = (Self._upTime = 0)
			Self._isPressed  = False
			Self._upTime :+  delta
			Self._lastTime   = Self._downTime
			Self._downTime	 = 0
		End If
	End Method

	' Reset better?
	Method flush()
		Self._isPressed  = False
		Self._isReleased = False
	End Method

End Type
