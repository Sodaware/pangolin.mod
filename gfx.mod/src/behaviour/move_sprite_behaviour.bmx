' ------------------------------------------------------------------------------
' -- sprite_animations/move_sprite_animation.bmx
' --
' -- Move a sprite for a specific duration.
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
	Field _elapsed:Float
	Field _speed:Float
	Field _xSpeed:Float
	Field _ySpeed:Float
	Field _targetX:Float
	Field _targetY:Float
	
	' TODO: We don't want to rely on FPS here, so we have to calculate this every frame using DELTA
	Method setDuration:MoveSpriteBehaviour(duration:Float)
		
		' Duration is duration in seconds
		Self._duration	= duration
		
		' Speed is amount it needs to move every frame
		Self._speed 	= (duration * 1000)
		
		' X speed = x distance * speed
		Self._xSpeed = (Self._targetX - Self.getTarget().getX()) / Self._speed
		Self._ySpeed = (Self._targety - Self.getTarget().getY()) / Self._speed
		
		Return Self
	End Method
	
	Method setTargetPosition:MoveSpriteBehaviour(xPos:Float, yPos:Float)
		Self._targetX = xPos
		Self._targetY = yPos
		Return Self
	End Method
	
	
	' --------------------------------------------------
	' -- Constructors
	' --------------------------------------------------
	

	Function Create:MoveSpriteBehaviour(target:AbstractRenderRequest, targetX:Float, targetY:Float, duration:Float)
		
		Local this:MoveSpriteBehaviour	= New MoveSpriteBehaviour
		this.setTarget(target)
		this.setTargetPosition(targetX, targetY)
		this.setDuration(duration)
		Return this

	End Function
	
	
	' --------------------------------------------------
	' -- Inherited functions (update/draw)
	' --------------------------------------------------
	
	Method update(delta:Float)
		
		' Move the sprite
		Self.getTarget().move(Self._xSpeed, Self._ySpeed)
		
		' Check if sprite is in its final position
		If Floor(Self.getTarget().getX()) = Floor(Self._targetX) And Floor(Self.getTarget().getY()) = Floor(Self._targetY) Then
			Self._isFinished = True
		End If
		
	End Method

End Type
