' ------------------------------------------------------------------------------
' -- src/actions/fade_sprite_action.bmx
' --
' -- Fade a sprite to an opacity over a set amount of time.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.actions
Import pangolin.gfx

Type FadeSpriteAction Extends BackgroundAction
	' Fade modes.
	Const FADE_IN:Byte          = 1
	Const KEEP:Byte             = 2
	Const FADE_OUT:Byte         = 3

	' Options.
	Field _fadeDuration:Float   = 1
	Field _keepDuration:Float   = 0
	Field _inverted:Byte        = False

	' Internal tracking.
	Field _fadeCounter:Float    = 0
	Field _fadeStep:Float       = 1
	Field _keepCounter:Float    = 0
	Field _keepStep:Float       = 0
	Field _frameCount:Int       = 0
	Field _fadeState:Byte       = 0
	Field _sprite:AbstractSpriteRequest


	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------

	Method setSprite:FadeSpriteAction(sprite:AbstractSpriteRequest)
		Self._sprite = sprite

		Return Self
	End Method

	''' <summary>Set the duration of the effect in milliseconds.</summary>
	Method setDuration:FadeSpriteAction(duration:Float)
		Self._fadeDuration = duration

		Return Self
	End Method

	Method setKeepDuration:FadeSpriteAction(duration:Float)
		Self._keepDuration = duration

		Return Self
	End Method

	''' <summary>
	''' Invert the animation.
	'''
	''' Inverted animations start at the final opacity and fade away. This can be
	''' used to fade the request in.
	''' </summary>
	Method invertAnimation:FadeSpriteAction(inverted:Byte = True)
		Self._inverted = inverted

		Return Self
	End Method

	Method isKeeping:Byte()
		Return Self._fadeState = FadeSpriteAction.KEEP
	End Method


	' ------------------------------------------------------------
	' -- Execution
	' ------------------------------------------------------------

	Method execute(delta:Float)
		' If just started, set alpha.
		If Self._fadeState = False Then
			Self._sprite.setAlpha(Self._inverted)
		EndIf

		If Self._fadeCounter < Self._fadeDuration Then
			Self._fadeCounter:+ delta

			If Self._inverted Then
				Self._fadeState = FadeSpriteAction.FADE_IN
				Self._sprite.setAlpha(Self._sprite.getAlpha() - Self._fadeStep)
			Else
				Self._fadeState = FadeSpriteAction.FADE_OUT
				Self._sprite.setAlpha(Self._sprite.getAlpha() + Self._fadeStep)
			End If
		Else
			Self._frameCount:+ 1
			Self._keepCounter:+ delta
			Self._fadeState = FadeSpriteAction.KEEP
		EndIf

	End Method

	Method isFinished:Byte()
		Return Self._fadeCounter >= Self._fadeDuration And Self._keepCounter >= Self._keepDuration
	End Method


	' ------------------------------------------------------------
	' -- Setup / Cleanup
	' ------------------------------------------------------------

	Method init()
		' Calculate the step
		' TODO: FPS needs to go here
		Self._fadeStep  = ( 1 / ( Self._fadeDuration / ( 1000 / 60 ) ) )
	End Method

End Type
