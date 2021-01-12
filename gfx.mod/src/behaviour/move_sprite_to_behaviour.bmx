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
	Field _xDistance:Float
	Field _yDistance:Float
	Field _startX:Float
	Field _startY:Float
	Field _endX:Float
	Field _endY:Float


	' --------------------------------------------------
	' -- Configuration
	' --------------------------------------------------

	Method setTarget(target:Object)
		Super.setTarget(target)

		Self._startX = Self._target.getX()
		Self._startY = Self._target.getY()
	End Method

	Method setDestination:MoveSpriteToBehaviour(xPos:Float, yPos:Float)
		Self._endX = xPos
		Self._endY = yPos

		Self._updateInternals()

		Return Self
	End Method


	' --------------------------------------------------
	' -- Inherited functions (update/draw)
	' --------------------------------------------------

	Method update(delta:Float)
		Super.update(delta)

		' Move the sprite.
		Self.getTarget().setX(Self.tween(Self._startX, Self._xDistance))
		Self.getTarget().setY(Self.tween(Self._startY, Self._yDistance))

		' If elapsed time is over, finish.
		If Self._elapsedTime > Self._duration Then
			Self.getTarget().setX(Self._endX)
			Self.getTarget().setY(Self._endY)

			Self.finished()
		End If

	End Method


	' --------------------------------------------------
	' -- Internal Helpers
	' --------------------------------------------------

	Method _updateInternals()
		Self._xDistance = Self._endX - Self._startX
		Self._yDistance = Self._endY - Self._startY
	End Method


	' --------------------------------------------------
	' -- Constructors
	' --------------------------------------------------

	Function Create:MoveSpriteToBehaviour(target:AbstractRenderRequest, targetX:Float, targetY:Float, duration:Float)
		Local this:MoveSpriteToBehaviour = New MoveSpriteToBehaviour

		this.setTarget(target)
		this.setDestination(targetX, targetY)
		this.setDuration(duration)

		Return this
	End Function

End Type
