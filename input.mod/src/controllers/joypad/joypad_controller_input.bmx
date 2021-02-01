' ------------------------------------------------------------------------------
' -- src/managers/joypad/joypad_controller_input.bmx
' --
' -- Controller input that hooks up to joypads.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pub.freejoy
Import "../base_controller_input.bmx"

' TODO: Move these to constants file

?win32
Const XBOX_BUTTON_A:Byte        = 0
Const XBOX_BUTTON_B:Byte        = 1
Const XBOX_BUTTON_X:Byte        = 2
Const XBOX_BUTTON_Y:Byte        = 3
Const XBOX_BUTTON_LB:Byte       = 4
Const XBOX_BUTTON_RB:Byte       = 5
Const XBOX_BUTTON_START:Byte    = 7
Const XBOX_BUTTON_SELECT:Byte   = 6
Const XBOX_BUTTON_LS_CLICK:Byte = 8
Const XBOX_BUTTON_RS_CLICK:Byte = 9
?

?linux
Const XBOX_BUTTON_A:Byte        = 0
Const XBOX_BUTTON_B:Byte        = 1
Const XBOX_BUTTON_X:Byte        = 2
Const XBOX_BUTTON_Y:Byte        = 3
Const XBOX_BUTTON_LB:Byte       = 4
Const XBOX_BUTTON_RB:Byte       = 5
Const XBOX_BUTTON_START:Byte    = 7
Const XBOX_BUTTON_SELECT:Byte   = 6
Const XBOX_BUTTON_LS_CLICK:Byte = 9
Const XBOX_BUTTON_RS_CLICK:Byte = 10
?

' joyhat - windows only?
Const XBOX_BUTTON_DPAD_UP:Float    = 0
Const XBOX_BUTTON_DPAD_DOWN:Float  = 0.5
Const XBOX_BUTTON_DPAD_LEFT:Float  = 0.75
Const XBOX_BUTTON_DPAD_RIGHT:Float = 0.25

Type JoypadControllerInput Extends BaseControllerInput
	Function build:JoypadControllerInput(name:String)
		Select name
			Case "yaw_left"    ; Return JoypadYawControllerInput.Create(-1)
			Case "yaw_right"   ; Return JoypadYawControllerInput.Create(1)
			Case "pitch_up"    ; Return JoypadPitchControllerInput.Create(-1)
			Case "pitch_down"  ; Return JoypadPitchControllerInput.Create(1)
			Case "hat_up"      ; Return JoypadHatControllerInput.Create(XBOX_BUTTON_DPAD_UP)
			Case "hat_down"    ; Return JoypadHatControllerInput.Create(XBOX_BUTTON_DPAD_DOWN)
			Case "hat_left"    ; Return JoypadHatControllerInput.Create(XBOX_BUTTON_DPAD_LEFT)
			Case "hat_right"   ; Return JoypadHatControllerInput.Create(XBOX_BUTTON_DPAD_RIGHT)

			Default
				' Buttons
				If name.startsWith("button_") Then
					Local buttonName:String = name.Replace("button_", "")
					Return JoypadButtonControllerInput.CreateSingle(Int(buttonName))
				EndIf
		End Select
	End Function
End Type

Type JoypadButtonControllerInput Extends JoypadControllerInput

	Field _buttons:Byte[]

	Method _inputDown()
		Local isDown:Byte = False

		For Local code:Byte = EachIn Self._buttons
			If JoyDown(code) Then isDown = True
		Next

		Self._isDown = isDown
	End Method

	Method _inputUp()
		Local isDown:Byte = True

		For Local code:Byte = EachIn Self._buttons
			If JoyDown(code) Then isDown = False
		Next

		Self._isDown = isDown
	End Method

	Function Create:JoypadButtonControllerInput(buttons:Byte[])
		Local this:JoypadButtonControllerInput = New JoypadButtonControllerInput

		this._buttons = buttons

		Return this
	End Function

	Function CreateSingle:JoypadButtonControllerInput(button:Int)
		Local this:JoypadButtonControllerInput = New JoypadButtonControllerInput

		this._buttons = [Byte(button)]

		Return this
	End Function

End Type


Type JoypadHatControllerInput Extends JoypadControllerInput

	Field _direction:Float

	Method _inputDown()
		Self._isDown = (JoyHat() = Self._direction)
	End Method

	Method _inputUp()
		Self._isDown = Not(JoyHat() = Self._direction)
	End Method

	Function Create:JoypadHatControllerInput(direction:Float)
		' TODO: Check the input
		Local this:JoypadHatControllerInput = New JoypadHatControllerInput

		this._direction = direction

		Return this
	End Function

End Type

Type JoypadYawControllerInput Extends JoypadControllerInput

	Field _direction:Float

	Method _inputDown()
		Self._isDown = (JoyYaw() = Self._direction)
	End Method

	Method _inputUp()
		Self._isDown = Not(JoyYaw() = Self._direction)
	End Method

	Function Create:JoypadYawControllerInput(direction:Float)
		' TODO: Check the input
		Local this:JoypadYawControllerInput = New JoypadYawControllerInput

		this._direction = direction

		Return this
	End Function

End Type

Type JoypadPitchControllerInput Extends JoypadControllerInput

	Field _direction:Float

	Method _inputDown()
		Self._isDown = (JoyPitch() = Self._direction)
	End Method

	Method _inputUp()
		Self._isDown = Not(JoyPitch() = Self._direction)
	End Method

	Function Create:JoypadPitchControllerInput(direction:Float)
		' TODO: Check the input
		Local this:JoypadPitchControllerInput = New JoypadPitchControllerInput

		this._direction = direction

		Return this
	End Function

End Type
