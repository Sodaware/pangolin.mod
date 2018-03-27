' ------------------------------------------------------------------------------
' -- sprite_behaviours/scale_sprite_behaviour.bmx
' --
' -- Scale a sprite from a size to a size. Scales the X and Y dimensions
' -- together.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2018 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "sprite_behaviour.bmx"

Type ScaleSpriteBehaviour Extends SpriteBehaviour

	Field _duration:Float
	Field _scaleSpeed:Float
	Field _scale:Float
	Field _fromScale:Float
	Field _toScale:Float


	' --------------------------------------------------
	' -- Inherited functions (update/draw)
	' --------------------------------------------------

	Method onStart()
		Self._scale = Self._fromScale
		Self.getTarget().setScale(Self._scale, Self._scale)
	End Method

	Method update(delta:Float)
		Super.update(delta)

		' Update scale size.
		Self._scale :+ (Self._scaleSpeed * delta)

		' Move the sprite
		Self.getTarget().setScale(Self._scale, Self._scale)

		' If elapsed time is over, finish.
		If Self._elapsedTime > Self._duration Then

			' Shuffle back slightly
			Local diff:Float   = Self._elapsedTime - Self._duration
			Local offset:Float = diff * Self._scaleSpeed
			Self.getTarget().setScale(Self._scale - offset, Self._scale - offset)

			' Finish
			Self.finished()
		End If
	End Method


	' --------------------------------------------------
	' -- Constructors
	' --------------------------------------------------

	Function Create:ScaleSpriteBehaviour(target:AbstractRenderRequest, fromScale:Float, toScale:Float, duration:Float)
		Local this:ScaleSpriteBehaviour = New ScaleSpriteBehaviour

		this.setTarget(target)

		this._fromScale = fromScale
		this._toScale   = toScale
		this._duration  = duration

		this._scaleSpeed = (toScale - fromScale) / duration

		Return this
	End Function

End Type
