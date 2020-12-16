' ------------------------------------------------------------------------------
' -- sprite_animations/move_sprite_animation.bmx
' --
' -- Move a sprite a distance over a specific duration.
' --
' -- For example, moving a sprite 100 pixels in 100 seconds would move the
' -- sprite 1 pixel each second.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../renderer/abstract_sprite_request.bmx"
Import "sprite_behaviour.bmx"

Type MoveSpriteBehaviour Extends SpriteBehaviour
	Field _xDistance:Float
	Field _yDistance:Float
	Field _startX:Float
	Field _startY:Float
	Field _endX:Float
	Field _endY:Float


	' --------------------------------------------------
	' -- Configuration
	' --------------------------------------------------

	''' <summary>Set the X and Y distance the sprite should move.</summary>
	Method setDistance:MoveSpriteBehaviour(xDistance:Float, yDistance:Float)
		Self._xDistance = xDistance
		Self._yDistance = yDistance

		self._updateInternals()

		Return Self
	End Method


	' --------------------------------------------------
	' -- Inherited functions (update/draw)
	' --------------------------------------------------

	Method update(delta:Float)
		Super.update(delta)

		' Move the sprite.
		Self.getTarget().move( ..
			Self.tween(Self._startX, Self._xDistance) - Self.getTarget().getX(), ..
			Self.tween(Self._startY, Self._yDistance) - Self.getTarget().getY() ..
		)

		' If elapsed time is over, finish.
		If Self._elapsedTime >= Self._duration Then
			' Adjust to the end part.
			Self.getTarget().move( ..
				Self._endX - Self.getTarget().getX(), ..
				Self._endY - Self.getTarget().getY() ..
			)

			Self.finished()
		End If
	End Method


	' --------------------------------------------------
	' -- Internal Helpers
	' --------------------------------------------------

	Method _updateInternals()
		Self._endX = Self._startX + Self._xDistance
		Self._endY = Self._startY + Self._yDistance
	End Method


	' --------------------------------------------------
	' -- Construction.
	' --------------------------------------------------

	''' <summary>Move a sprite xDistance and yDistance in duration milliseconds.</summary>
	Function Create:MoveSpriteBehaviour(target:AbstractRenderRequest, xDistance:Float, yDistance:Float, duration:Float)
		Local this:MoveSpriteBehaviour = New MoveSpriteBehaviour

		this._startX = target.getX()
		this._startY = target.getY()

		this.setTarget(target)
		this.setDistance(xDistance, yDistance)
		this.setDuration(duration)

		Return this
	End Function

End Type
