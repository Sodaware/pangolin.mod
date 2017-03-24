' ------------------------------------------------------------------------------
' -- src/renderer/sprite_animation/rotate_sprite_animation.bmx
' --
' -- Rotate a sprite.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "sprite_animation.bmx"


Type RotateSpriteAnimation Extends SpriteAnimation

	Field _rotationSpeed:Float
	Field _maxRotations:Int
	
	' Internal stuff
	Field _angle:Float
	Field _rotateCount:Int

	' TODO: We don't want to rely on FPS here, so we have to calculate this every frame using DELTA
	Method setSpeed:RotateSpriteAnimation(speed:Float)
		Self._rotationSpeed = (speed / 1000) * 360
		Return Self
	End Method
	
	Method setMaxRotations:RotateSpriteAnimation(maxRotations:Int)
		Self._maxRotations = maxRotations
		Return Self
	End Method
	
	' --------------------------------------------------
	' -- Constructors
	' --------------------------------------------------
	

	Function Create:RotateSpriteAnimation()
		
		Local this:RotateSpriteAnimation	= New RotateSpriteAnimation	
		Return this

	End Function
	
	
	' --------------------------------------------------
	' -- Inherited functions (update/draw)
	' --------------------------------------------------
	
	Method update(delta:Float)
		Self._angle:+ (Self._rotationSpeed * delta)
		Self.getParent().SetRotation(Self._angle)
		
		If Self._angle > 360 Then
			Self._rotateCount:+ 1
			
			If Self._rotateCount >= Self._maxRotations Then
				Self.finished()
			Else
				Self._angle:- 360
			End If
		EndIf	
		
	End Method

	Method New()
		Self._rotationSpeed = 1
		Self._maxRotations	= 1
		Self._rotateCount	= 0
	End Method
	
End Type
