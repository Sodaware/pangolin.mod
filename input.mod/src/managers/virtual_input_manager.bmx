' ------------------------------------------------------------------------------
' -- src/managers/virtual_input_manager.bmx
' --
' -- Manages virtual controllers. Prefer using `VirtualInputService`, but this
' -- manager can be used outside of the kernel if desired.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../controllers/virtual_controller.bmx"

Type VirtualInputManager
	Field _controllers:VirtualController[]

	Method addController(pad:VirtualController)
		' Don't add if array already contains it.
		If Self._findController(pad) <> -1 Then Return

		Self._controllers = Self._controllers[..Self._controllers.length + 1]
		Self._controllers[Self._controllers.length - 1] = pad
	End Method

	Method removeController(pad:VirtualController)
		Local pos:Int = Self._findController(pad)
		If pos = -1 Then Return

		' Switch with final controller and remove.
		Self._controllers[pos] = Self._controllers[Self._controllers.length - 1]
		Self._controllers = Self._controllers[..Self._controllers.length - 1]
	End Method

	Method getController:VirtualController(offset:Byte = 0)
		If offset >= Self._controllers.length Then Return Null

		Return Self._controllers[offset]
	End Method

	Method update(delta:Float)
		For Local pad:VirtualController = EachIn Self._controllers
			pad.update(delta)
		Next
	End Method

	Method flush()
		For Local pad:VirtualController = EachIn Self._controllers
			pad.flush()
		Next
	End Method

	Method _findController:Int(pad:VirtualController)
		If Self._controllers.length = 0 Then Return -1

		For Local i:Byte = 0 To Self._controllers.length - 1
			If Self._controllers[i] = pad Then Return i
		Next

		Return -1
	End Method

End Type
