' ------------------------------------------------------------------------------
' -- sprite_animations/pixel_move_sprite_animation.bmx
' --
' -- Move a sprite a specific number of pixels.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "sprite_behaviour.bmx"


Type PixelMoveSpriteBehaviour Extends SpriteBehaviour

	Field _xSpeed:Float
	Field _ySpeed:Float
	Field _targetX:Float
	Field _targetY:Float
	Field _elapsed:Int
	Field _duration:Int
	
	Method setTargetPosition:PixelMoveSpriteBehaviour(xPos:Float, yPos:Float)
		Self._targetX = xPos
		Self._targetY = yPos
		Return Self
	End Method
	
	Method setSpeed:PixelMoveSpriteBehaviour(xSpeed:Float, ySpeed:Float)
		Self._xSpeed = xSpeed
		Self._ySpeed = ySpeed
		Return Self
	End Method
	
	
	' --------------------------------------------------
	' -- Constructors
	' --------------------------------------------------
	
	'' Duration is number of frames
	Function Create:PixelMoveSpriteBehaviour(target:AbstractRenderRequest, xSpeed:Float, ySpeed:Float, duration:Int, transition:Int = SpriteBehaviour.EASING_LINEAR)
		
		Local this:PixelMoveSpriteBehaviour	= New PixelMoveSpriteBehaviour
		this.setTarget(target)
		this.setSpeed(xSpeed, ySpeed)
		this.setDuration(duration)
		this.setEasingType(transition)
		Return this

	End Function
	
	
	' --------------------------------------------------
	' -- Inherited functions (update/draw)
	' --------------------------------------------------
	
	Method update(delta:Float)
		
		' Move the sprite
		Self.getTarget().move(Self._xSpeed, Self._ySpeed)
		
		Self._elapsed:+ 1
		If Self._elapsed = Self._duration Then Self._isFinished = True
		
	End Method

End Type
