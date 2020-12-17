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

''' <summary>
''' Moves a sprite a set number of pixels on the X and Y axes over a set time.
'''
''' This behaviour does not calculate co-ordinates, so it can be used in
''' combination with other movers.
''' </summary>
Type MoveSpriteBehaviour Extends SpriteBehaviour
	Field _xDistance:Float              ' The X distance this sprite will travel.
	Field _yDistance:Float              ' The Y distance this sprite will travel.
	Field _xLast:Float                  ' The total X travelled (previous frame).
	Field _yLast:Float                  ' The total Y travelled (previous frame).


	' --------------------------------------------------
	' -- Configuration
	' --------------------------------------------------

	''' <summary>Set the X and Y distance the sprite should move.</summary>
	Method setDistance:MoveSpriteBehaviour(xDistance:Float, yDistance:Float)
		Self._xDistance = xDistance
		Self._yDistance = yDistance

		Return Self
	End Method


	' --------------------------------------------------
	' -- Inherited functions (update/draw)
	' --------------------------------------------------

	Method update(delta:Float)
		Super.update(delta)

		' Calculate the delta to move and adjust the sprite.
		Self.getTarget().move(Self._xDelta(), Self._yDelta())

		' If time is over, adjust the sprite to its final position and finish.
		If Self._elapsedTime >= Self._duration Then
			Self.getTarget().move( ..
				Self._xDistance - Self._xLast , ..
				Self._yDistance - Self._yLast ..
			)

			Self.finished()
		End If
	End Method


	' --------------------------------------------------
	' -- Internal helpers
	' --------------------------------------------------

	Method _xDelta:Float()
		' Do nothing no movement at all on the x axis.
		If Self._xDistance = 0 Then Return 0

		' Calculate the amount to move.
		Local xMovement:Float = Self.tween(0, Self._xDistance)
		Local xOffset:Float   = xMovement - Self._xLast

		' Store the tweened value so we can calculate a delta.
		Self._xLast = xMovement

		Return xOffset
	End Method

	Method _yDelta:Float()
		' Do nothing no movement at all on the y axis.
		If Self._yDistance = 0 Then Return 0

		' Calculate the amount to move.
		Local yMovement:Float = Self.tween(0, Self._yDistance)
		Local yOffset:Float   = yMovement - Self._yLast

		' Store the tweened value so we can calculate a delta.
		Self._yLast = yMovement

		Return yOffset
	End Method


	' --------------------------------------------------
	' -- Construction.
	' --------------------------------------------------

	''' <summary>Move a sprite xDistance and yDistance in duration milliseconds.</summary>
	Function Create:MoveSpriteBehaviour(target:AbstractRenderRequest, xDistance:Float, yDistance:Float, duration:Float)
		Local this:MoveSpriteBehaviour = New MoveSpriteBehaviour

		this.setTarget(target)
		this.setDistance(xDistance, yDistance)
		this.setDuration(duration)

		Return this
	End Function

End Type
