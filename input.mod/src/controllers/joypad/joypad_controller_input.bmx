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
Import "joypad_controller_constants.bmx"

Type JoypadControllerInput Extends BaseControllerInput
	Function build:JoypadControllerInput(name:String)
		Select name
			Case "dpad_left"   ; Return JoypadXControllerInput.Create(-1)
			Case "dpad_right"  ; Return JoypadXControllerInput.Create(1)
			Case "dpad_up"     ; Return JoypadYControllerInput.Create(-1)
			Case "dpad_down"   ; Return JoypadYControllerInput.Create(1)
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

Type JoypadXControllerInput Extends JoypadControllerInput
	Field _direction:Float

	Method _inputDown()
		Self._isDown = (JoyX() = Self._direction)
	End Method

	Method _inputUp()
		Self._isDown = Not(JoyX() = Self._direction)
	End Method

	Function Create:JoypadXControllerInput(direction:Float)
		Local this:JoypadXControllerInput = New JoypadXControllerInput

		this._direction = direction

		Return this
	End Function
End Type

Type JoypadYControllerInput Extends JoypadControllerInput
	Field _direction:Float

	Method _inputDown()
		Self._isDown = (JoyY() = Self._direction)
	End Method

	Method _inputUp()
		Self._isDown = Not(JoyY() = Self._direction)
	End Method

	Function Create:JoypadYControllerInput(direction:Float)
		Local this:JoypadYControllerInput = New JoypadYControllerInput

		this._direction = direction

		Return this
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
