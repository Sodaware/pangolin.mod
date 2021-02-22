' ------------------------------------------------------------------------------
' -- src/actions/fade_screen_action.bmx
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.actions
Import pangolin.gfx

Type FadeScreenAction Extends BackgroundAction

	Const FADE_IN:Byte          = 1
	Const KEEP:Byte             = 2
	Const FADE_OUT:Byte         = 3

	' Options
	Field _color:Int			= 0	'< TODO: FIX THIS! Use an RgbColor object or something. Anything.
	Field _fadeDuration:Float	= 1
	Field _keepDuration:Float	= 0
	Field _inverted:Byte		= False

	' Internal tracking
	Field _fadeCounter:Float	= 0
	Field _fadeStep:Float		= 1
	Field _keepCounter:Float	= 0
	Field _keepStep:Float		= 0
	Field _frameCount:Int       = 0
	Field _fadeState:Byte       = 0
	Field _overlay:RectangleRenderRequest

	' Services
	Field _renderer:SpriteRenderingService


	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------

	''' <summary>Set the final color (as an int).</summary>
	Method setFinalColor:FadeScreenAction(color:Int)
		Self._color = color

		Return Self
	End Method

	''' <summary>Set the duration of the effect in milliseconds.</summary>
	Method setDuration:FadeScreenAction(duration:Float)
		Self._fadeDuration = duration

		Return Self
	End Method

	Method setKeepDuration:FadeScreenAction(duration:Float)
		Self._keepDuration = duration

		Return Self
	End Method

	''' <summary>
	''' Invert the animation.
	'''
	''' Inverted animations start at the final colour and fade away. This can be
	''' used to fade the screen in from a colour.
	''' </summary>
	Method invertAnimation:FadeScreenAction(inverted:Byte)
		Self._inverted = inverted

		Return Self
	End Method

	Method isKeeping:Byte()
		Return Self._fadeState = FadeScreenAction.KEEP
	End Method


	' ------------------------------------------------------------
	' -- Execution
	' ------------------------------------------------------------

	Method execute(delta:Float)

		' TODO: After loading there's a stupidly high delta caused by something or other...
		If delta > 100 Then
			DebugLog "DELTA: " + delta
			Return
		EndIf

		' Fade
		If Self._fadeCounter < Self._fadeDuration Then

			Self._fadeCounter:+ delta

			If Self._inverted Then
				Self._fadeState = FadeScreenAction.FADE_IN
				Self._overlay.setBackgroundAlpha(Self._overlay._backgroundAlpha - Self._fadeStep)
			Else
				Self._fadeState = FadeScreenAction.FADE_OUT
				Self._overlay.setBackgroundAlpha(Self._overlay._backgroundAlpha + Self._fadeStep)
			End If
		Else
			Self._frameCount:+ 1
			Self._keepCounter:+ delta
			Self._fadeState = FadeScreenAction.KEEP
		EndIf

	End Method

	Method isFinished:Byte()
		Return Self._fadeCounter >= Self._fadeDuration And Self._keepCounter >= Self._keepDuration
	End Method


	' ------------------------------------------------------------
	' -- Setup / Cleanup
	' ------------------------------------------------------------

	Method init()
		Self._renderer = SpriteRenderingService(Self.getKernel().getServiceByName("SpriteRenderingService"))
		Local effectsGroup:RenderGroup = Self._renderer.getGroup("effects")

		' If the effects group doesn't exist, don't add the action
		If Null = effectsGroup Then
			Self._fadeCounter = 1000
			Self._keepCounter = 1000
			Return
		End If

		' Create a rectangle
		Self._overlay = RectangleRenderRequest.Create(0, 0, PangolinGfx.getGraphicsWidth(), PangolinGfx.getGraphicsHeight())
		Self._overlay.ignoreCamera()
		Self._overlay.setBlendMode(ALPHABLEND)

		If Self._inverted Then
			Self._overlay.setBackgroundAlpha(1)
		Else
			Self._overlay.setBackgroundAlpha(0)
		EndIf

		Self._overlay.setBackgroundColor(0, 0, 0)

		effectsGroup.add(Self._overlay)

		' Calculate the step
		' TODO: FPS needs to go here
		Self._fadeStep = ( 1 / ( Self._fadeDuration / ( 1000 / 60 ) ) )

	End Method

	Method onFinish()
		Super.onFinish()
		' TODO: Fix this!
		If Self._renderer.getGroup("effects") Then
			Self._renderer.getGroup("effects").remove(Self._overlay)
		EndIf
	End Method

End Type
