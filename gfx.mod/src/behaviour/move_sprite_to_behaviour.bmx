' ------------------------------------------------------------------------------
' -- src/behaviour/move_sprite_to_animation.bmx
' --
' -- Move a request to a location over a specific duration.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2020 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "sprite_behaviour.bmx"

''' <summary>
''' Move a request to a location over a specific duration.
'''
''' This will smoothly move a render request from one place to another. It's
''' useful for requests that ignore the camera.
''' </summary>
Type MoveSpriteToBehaviour Extends SpriteBehaviour
	Field _duration:Float
	Field _xSpeed:Float
	Field _ySpeed:Float
	Field _xDistance:Float
	Field _yDistance:Float

	''' <summary>Set the duration of movement in milliseconds.</summary>
	Method setDuration:MoveSpriteToBehaviour(duration:Float)
		Self._duration = duration

		self._updateInternals()

		Return Self
	End Method

	Method setTargetPosition:MoveSpriteToBehaviour(xPos:Float, yPos:Float)
		Self._xDistance = xPos - Self._target.getX()
		Self._yDistance = yPos - Self._target.getY()

		Self._updateInternals()

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
	' -- Constructors
	' --------------------------------------------------


	Function Create:MoveSpriteToBehaviour(target:AbstractRenderRequest, targetX:Float, targetY:Float, duration:Float)

		Local this:MoveSpriteToBehaviour	= New MoveSpriteToBehaviour
		this.setTarget(target)
		this.setTargetPosition(targetX, targetY)
		this.setDuration(duration)
		Return this

	End Function

End Type
