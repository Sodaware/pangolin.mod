' ------------------------------------------------------------------------------
' -- src/renderer/sprite_animation/fade_sprite_animation.bmx
' --
' -- Fades a sprite in, waits, then fades out. Can also be used to fade in or
' -- fade out.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.max2d

Import "sprite_animation.bmx"

Type FadeSpriteAnimation Extends SpriteAnimation

	Const FADE_IN:Int	= 1
	Const FADE_OUT:Int	= 2
	Const DISPLAY:Int	= 3

	Field _fadeInTime:Int
	Field _displayTime:Int
	Field _fadeOutTime:Int

	Field _repeatLimit:Int

	' -- Internal
	Field _alpha:Float
	Field _alphaStep:Float
	Field _state:Int
	Field _elapsedTime:Int
	Field _repeatCount:Int


	' ------------------------------------------------------------
	' -- Setting Options
	' ------------------------------------------------------------

	Method setFadeInTime:FadeSpriteAnimation(time:Int)
		Self._fadeInTime = time
		Self._updateInternals()
		Return Self
	End Method

	Method setDisplayTime:FadeSpriteAnimation(time:Int)
		Self._displayTime = time
		Self._updateInternals()
		Return Self
	End Method

	Method setFadeOutTime:FadeSpriteAnimation(time:Int)
		Self._fadeOutTime = time
		Self._updateInternals()
		Return Self
	End Method


	' ------------------------------------------------------------
	' -- Updating
	' ------------------------------------------------------------

	Method update(delta:Float)

		Self._elapsedTime:+ delta

		Select Self._state

			Case FadeSpriteAnimation.FADE_IN;
				Self._updateFadeIn()

			Case FadeSpriteAnimation.DISPLAY;
				Self._updateDisplay()

			Case FadeSpriteAnimation.FADE_OUT;
				Self._updateFadeOut()

		End Select

		Self.getParent().setBlendMode(ALPHABLEND)
		Self.getParent().SetAlpha(Self._alpha)

	End Method


	Method reset()
		Self._state			= FadeSpriteAnimation.FADE_IN
		Self._elapsedTime	= 0
		Self._alphaStep		= Self._calculateAlphaStep(Self._fadeInTime)
		Self._alpha			= 0
	End Method


	' ------------------------------------------------------------
	' -- Internal Update Helpers
	' ------------------------------------------------------------

	Method _updateFadeIn()

		Self._alpha:+ Self._alphaStep

		If Self._elapsedTime > Self._fadeInTime Then
			Self._setState(Self.DISPLAY)
			Self._elapsedTime	= 0
			Self._alpha			= 1
		End If

	End Method

	Method _updateDisplay()

		If Self._elapsedTime > Self._displayTime Then
			Self._setState(Self.FADE_OUT)
			Self._alphaStep		= Self._calculateAlphaStep(Self._fadeOutTime)
			Self._alpha			= 1
		End If

	End Method

	Method _updateFadeOut()

		Self._alpha:- Self._alphaStep

		If Self._elapsedTime > Self._fadeOutTime Then

			Self._repeatCount:+ 1

			' Do we repeat?
			If Self._repeatCount <= Self._repeatLimit Then
				Self.reset()
			Else
				Self.finished()
			End If

		End If

	End Method


	' ------------------------------------------------------------
	' -- Internal Helpers
	' ------------------------------------------------------------

	Method _setState(state:Int)
		Self._state			= state
		Self._elapsedTime	= 0
	End Method

	Method _updateInternals()

		Self._alphaStep		= Self._calculateAlphaStep(Self._fadeInTime)
		Self._alpha			= 0
		Self._state			= FadeSpriteAnimation.FADE_IN

		If Self._fadeInTime = 0 Then
			If Self._displayTime = 0 Then
				Self._state = FadeSpriteAnimation.FADE_OUT
			Else
				Self._state = FadeSpriteAnimation.DISPLAY
			EndIf
		EndIf

	End Method

	Method _calculateAlphaStep:Float(time:Int)
		local hertz:Int = GraphicsHertz()
		if hertz <= 0 then hertz = 60
		Return Float(1 / Float(time)) * (1000 / Float(hertz))
	End Method


	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------

	Function Create:FadeSpriteAnimation(fadeInTime:Int, displayTime:Int, fadeOutTime:Int, repeatLimit:Int = 0)

		Local this:FadeSpriteAnimation	= New FadeSpriteAnimation

		this._fadeInTime	= fadeInTime
		this._fadeOutTime	= fadeOutTime
		this._displayTime	= displayTime
		this._repeatLimit	= repeatLimit

		this._updateInternals()

		Return this

	End Function

	Method New()
		Self._alpha		= 1
		Self._alphaStep	= 0
	End Method
End Type
