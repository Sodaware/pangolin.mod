' ------------------------------------------------------------------------------
' -- sprite_animations/fade_sprite_animation.bmx
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

Import brl.linkedlist
Import brl.max2d

Import "sprite_behaviour.bmx"
Import "../renderer/abstract_sprite_request.bmx"

Type FadeSpriteBehaviour Extends SpriteBehaviour

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
	Field _repeatCount:Int


	' ------------------------------------------------------------
	' -- Setting Options
	' ------------------------------------------------------------

	Method setFadeInTime:FadeSpriteBehaviour(time:Int)
		Self._fadeInTime = time
		Self._updateInternals()
		Return Self
	End Method

	Method setDisplayTime:FadeSpriteBehaviour(time:Int)
		Self._displayTime = time
		Self._updateInternals()
		Return Self
	End Method

	Method setFadeOutTime:FadeSpriteBehaviour(time:Int)
		Self._fadeOutTime = time
		Self._updateInternals()
		Return Self
	End Method


	' ------------------------------------------------------------
	' -- Updating
	' ------------------------------------------------------------

	Method update(delta:Float)

		Super.update(delta)

		Select Self._state

			Case FadeSpriteBehaviour.FADE_IN
				Self._updateFadeIn(delta)

			Case FadeSpriteBehaviour.DISPLAY
				Self._updateDisplay(delta)

			Case FadeSpriteBehaviour.FADE_OUT
				Self._updateFadeOut(delta)

		End Select

		Self.getTarget().setBlendMode(ALPHABLEND)
		Self.getTarget().setAlpha(Self._alpha)

	End Method

	Method reset()
		Self._state			= FadeSpriteBehaviour.FADE_IN
		Self._elapsedTime	= 0
		Self._alphaStep		= Self._calculateAlphaStep(Self._fadeInTime)
		Self._alpha			= 0
	End Method


	' ------------------------------------------------------------
	' -- Internal Update Helpers
	' ------------------------------------------------------------

	Method _updateFadeIn(delta:Float)

		self.getTarget().show()

		Self._alpha:+ (Self._alphaStep * delta)

		If Self._elapsedTime > Self._fadeInTime Then
			Self._setState(Self.DISPLAY)
			Self._alpha = 1
		End If

	End Method

	Method _updateDisplay(delta:Float)

		If Self._elapsedTime > Self._displayTime Then
			Self._setState(Self.FADE_OUT)
			Self._alphaStep	= Self._calculateAlphaStep(Self._fadeOutTime)
			Self._alpha = 1
		End If

	End Method

	Method _updateFadeOut(delta:Float)

		If Self._fadeOutTime < 0 Then
			Self.endLoop()
			Return
		End If

		Self._alpha:- (Self._alphaStep * delta)

		If Self._elapsedTime > Self._fadeOutTime Then
			Self.endLoop()
		End If

	End Method

	Method endLoop()
		Self._repeatCount:+ 1

		If Self._repeatCount <= Self._repeatLimit Then
			Self.reset()
		Else
			Self.finished()
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

		Self._alphaStep	= Self._calculateAlphaStep(Self._fadeInTime)
		Self._alpha     = 0
		Self._state     = FadeSpriteBehaviour.FADE_IN

		If Self._fadeInTime = 0 Then
			If Self._displayTime = 0 Then
				Self._alphaStep	= Self._calculateAlphaStep(Self._fadeOutTime)
				Self._alpha     = 1
				Self._state     = FadeSpriteBehaviour.FADE_OUT
			Else
				Self._state = FadeSpriteBehaviour.DISPLAY
			EndIf
		EndIf

	End Method

	Method _calculateAlphaStep:Float(time:Float)
		Return 1.0 / time
'		Return Float(1 / Float(time)) * (1000 / Float(hertz))
	End Method


	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------

	Function Create:FadeSpriteBehaviour(request:AbstractRenderRequest, fadeInTime:Int, displayTime:Int, fadeOutTime:Int, repeatLimit:Int = 0)

		Local this:FadeSpriteBehaviour	= New FadeSpriteBehaviour

		this.setTarget(request)
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
