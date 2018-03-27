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

Import "sprite_behaviour.bmx"

Type MoveSpriteBehaviour Extends SpriteBehaviour

	Field _duration:Float
	Field _xSpeed:Float
	Field _ySpeed:Float
	Field _xDistance:Float
	Field _yDistance:Float


	' --------------------------------------------------
	' -- Configuration
	' --------------------------------------------------

	''' <summary>Set the duration of movement in milliseconds.</summary>
	Method setDuration:MoveSpriteBehaviour(duration:Float)
		Self._duration = duration

		self._updateInternals()

		Return Self
	End Method

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

		' Move the sprite
		Self.getTarget().move(Self._xSpeed * delta, Self._ySpeed * delta)

		' If elapsed time is over, finish.
		If Self._elapsedTime > Self._duration Then
			' Shuffle back slightly
			Local diff:Float = Self._elapsedTime - Self._duration
			Local xOff:Float = diff * Self._xSpeed
			Local yOff:Float = diff * Self._ySpeed
			Self.getTarget().move(0 - xOff, 0 - yOff)

			' Finish
			Self.finished()
		End If

	End Method


	' --------------------------------------------------
	' -- Internal Helpers
	' --------------------------------------------------

	Method _updateInternals()
		Self._xSpeed = Self._xDistance / Self._duration
		Self._ySpeed = Self._yDistance / Self._duration
	End Method


	' --------------------------------------------------
	' -- Construction.
	' --------------------------------------------------

	''' <summary>Move a sprite xDistance and yDistance in duration milliseconds.</summary>
	Function Create:MoveSpriteBehaviour(target:AbstractRenderRequest, xDistance:Float, yDistance:Float, duration:Float)

		Local this:MoveSpriteBehaviour	= New MoveSpriteBehaviour
		this.setTarget(target)
		this.setDistance(xDistance, yDistance)
		this.setDuration(duration)
		Return this

	End Function

End Type
