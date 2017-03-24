' ------------------------------------------------------------------------------
' -- sprite_animations/physics_move_animation.bmx
' --
' -- Move a sprite for a duration, but apply gravity.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "sprite_behaviour.bmx"

' TODO: Add acceleration/drag etc here.
Type PhysicsMoveSpriteBehaviour Extends SpriteBehaviour

	Field _duration:Float
	Field _elapsed:Float
	Field _xSpeed:Float
	Field _ySpeed:Float
	
	Field _gravity:Float
	
	Method setDuration:PhysicsMoveSpriteBehaviour(duration:Float)
		Self._duration = duration
		Return Self
	End Method
	
	Method setGravity:PhysicsMoveSpriteBehaviour(gravity:Float)
		Self._gravity = gravity
		Return Self
	End Method
	
	' --------------------------------------------------
	' -- Constructors
	' --------------------------------------------------
	

	Function Create:PhysicsMoveSpriteBehaviour(target:AbstractRenderRequest, xVelocity:Float, yVelocity:Float, duration:Float, gravity:Float = 0)
		
		Local this:PhysicsMoveSpriteBehaviour	= New PhysicsMoveSpriteBehaviour
		this.setTarget(target)
		this.setDuration(duration)
		this.setGravity(gravity)
		
		this._xSpeed = xVelocity
		this._ySpeed = yVelocity
		Return this

	End Function
	
	
	' --------------------------------------------------
	' -- Inherited functions (update/draw)
	' --------------------------------------------------
	
	Method update(delta:Float)
		
		' Update gravity
		Self._ySpeed :+ Self._gravity
	
		' Move the sprite
		Self.getTarget().move(Self._xSpeed, Self._ySpeed)
		
		Self._elapsed :+ delta
		
		If Self._elapsed > Self._duration Then
			Self._isFinished = True
		End If
		
	End Method

End Type
