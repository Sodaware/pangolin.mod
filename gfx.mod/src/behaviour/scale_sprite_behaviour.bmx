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
	Field _fromScale:Float
	Field _toScale:Float


	' --------------------------------------------------
	' -- Inherited functions (update/draw)
	' --------------------------------------------------

	Method onStart()
		Self.getTarget().setScale(Self._fromScale, Self._fromScale)
	End Method

	' TODO: When scaling from 1 to 0, setScale(1 - tween)
	Method update(delta:Float)
		Super.update(delta)

		' Scale the sprite.
		Self.getTarget().setScale( ..
			Self.tween(Self._fromScale, Self._toScale), ..
			Self.tween(Self._fromScale, Self._toScale) ..
		)

		' If elapsed time is over, finish.
		If Self._elapsedTime > Self._duration Then
			Self.getTarget().setScale(Self._toScale, Self._toScale)
			Self.finished()
		End If
	End Method


	' --------------------------------------------------
	' -- Constructors
	' --------------------------------------------------

	Function Create:ScaleSpriteBehaviour(target:AbstractRenderRequest, fromScale:Float, toScale:Float, duration:Float)
		Local this:ScaleSpriteBehaviour = New ScaleSpriteBehaviour

		this.setTarget(target)
		this.setDuration(duration)

		this._fromScale = fromScale
		this._toScale   = toScale

		Return this
	End Function

End Type
