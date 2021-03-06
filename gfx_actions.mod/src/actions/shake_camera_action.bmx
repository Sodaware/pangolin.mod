' ------------------------------------------------------------
' -- src/actions/shake_camera_action.bmx
' --
' -- Makes the camera shake.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.actions
Import pangolin.gfx

''' <summary>Makes the camera shake.</summary>
Type ShakeCameraAction Extends BackgroundAction
	Field _camera:RenderCamera
	Field _counter:Int = 0

	' Options
	Field _intensity:Float	= 2
	Field _duration:Float	= 120 ' ms


	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------

	''' <summary>Set the intensity of the shake effect.</summary>
	Method setIntensity:ShakeCameraAction(intensity:Float)
		Self._intensity = intensity

		Return Self
	End Method

	''' <summary>Set the duration of the effect in seconds.</summary>
	Method setDuration:ShakeCameraAction(duration:Float)
		Self._duration = (duration * 1000)

		Return Self
	End Method


	' ------------------------------------------------------------
	' -- Execution
	' ------------------------------------------------------------

	Method execute(delta:Float)
		Self._camera._position.addValue(Float(Rnd(-Self._intensity, Self._intensity)), Float(Rnd(-Self._intensity, Self._intensity)))
		Self._counter :+ delta
	End Method

	Method isFinished:Byte()
		Return Self._counter >= Self._duration
	End Method

	Method onFinish()
		super.onFinish()
		self._camera.setPosition(0, 0)
	End Method


	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------

	Function Create:ShakeCameraAction(intensity:Float = 2, duration:Float = 0.12)
		Local this:ShakeCameraAction = New ShakeCameraAction

		this.setIntensity(intensity)
		this.setDuration(duration)

		Return this
	End Function

	Method init()
		Local renderer:SpriteRenderingService = SpriteRenderingService(Self.getKernel().getServiceByName("SpriteRenderingService"))
		Self._camera = renderer.getCamera()
	End Method

End Type
