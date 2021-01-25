' ------------------------------------------------------------------------------
' -- src/controllers/keyboard/keyboard_controller_input.bmx
' --
' -- Handles input from keys on a keyboard.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.polledinput

Import "../base_controller_input.bmx"

Type KeyboardControllerInput Extends BaseControllerInput
	Field _keys:Int[]

	Method _inputDown()
		Self._isDown = False

		For Local code:Byte = EachIn Self._keys
			If KeyDown(code) Then
				Self._isDown = True
				Return
			EndIf
		Next
	End Method

	Method _inputUp()
		Self._isDown = True

		For Local code:Byte = EachIn Self._keys
			If KeyDown(code) Then
				Self._isDown = False

				Return
			EndIf
		Next
	End Method

	Function Create:KeyboardControllerInput(keys:Int[])
		Local this:KeyboardControllerInput = New KeyboardControllerInput

		this._keys = keys

		Return this
	End Function

End Type
