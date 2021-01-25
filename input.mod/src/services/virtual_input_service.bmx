' ------------------------------------------------------------------------------
' -- src/services/virtual_input_service.bmx
' --
' -- Service for managing custom input mapping. Wraps the InputManager, handles
' -- updates, and adds some helpers.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pub.freejoy
Import pangolin.core

Import "../managers/virtual_input_manager.bmx"

Type VirtualInputService Extends GameService ..
	{ implements = "update" }

	Field _inputManager:VirtualInputManager


	' ------------------------------------------------------------
	' -- Public API
	' ------------------------------------------------------------

	Method addController(pad:VirtualController)
		Self._inputManager.addController(pad)
	End Method

	Method removeController(pad:VirtualController)
		Self._inputManager.removeController(pad)
	End Method

	Method createController:VirtualController(port:Byte = 0)
		Local pad:VirtualController = New VirtualController

		Self.addController(pad)

		Return pad
	End Method

	Method flush()
		Self._inputManager.flush()
	End Method


	' ------------------------------------------------------------
	' -- Controller helpers
	' ------------------------------------------------------------

	Method getController:VirtualController(offset:Byte = 0)
		Return Self._inputManager.getController(offset)
	End Method

	Method hasJoysticks:Byte()
		Return JoyCount() > 0
	End Method


	' ------------------------------------------------------------
	' -- Updating / Rendering
	' ------------------------------------------------------------

	Method update(delta:float)
		Self._inputManager.update(delta)
	End Method


	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------

	Method New()
		Self._inputManager = New VirtualInputManager
	End Method

End Type
