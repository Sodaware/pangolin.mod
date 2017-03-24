' ------------------------------------------------------------------------------
' -- src/renderer/screen_objects/image_sprite.bmx
' -- 
' -- A renderable image sprite.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.max2d
Import pangolin.resources
Import "../abstract_sprite_request.bmx"

Include "../sprite_animation_handler.bmx"

Type ImageSprite Extends AbstractSpriteRequest

	Field _frame:Int								'''< Current frame
	Field _image:TImage								'''< Image strip to display
	Field _animationRunner:SpriteAnimationHandler	'''< Handles the animation
	Field _animation:AnimationResource				'''< The animation for this sprite
	
		
	' ------------------------------------------------------------
	' -- Animation Checking
	' ------------------------------------------------------------
	
	Method isAnimationFinished:Byte()
		If Self._animationRunner = Null Then Return True
		Return Not(Self._animationRunner.isPlaying())
	End Method
	
	
	' ------------------------------------------------------------
	' -- Setting image / frame
	' ------------------------------------------------------------
	
	Method setImage(image:TImage, frame:Int = 0)
		Self._image = image
		Self._frame = frame
	End Method
	
	Method setFrame(frame:Int = 0)
		Self._frame = frame
	End Method
	
	Method setAnimation(animation:AnimationResource)
		Self._animation = animation
	End Method
	
	Method play(animationName:String, speed:Float = 1.0)
		Self._animationRunner.play(animationName)
	End Method
	
	Method stopAnimation()
		Self._animationRunner.stop()
	End Method
	
	Method setFrameTime(frameTime:Int)
		Self._animationRunner._animationFrameTime = frameTime
	End Method
	
	
	' ------------------------------------------------------------
	' -- Rendering
	' ------------------------------------------------------------
	
	Method update(delta:Float)
		Super.update(delta)
		Self._animationRunner.update(delta)
	End Method
	
	Method render(delta:Double, camera:AbstractRenderCamera, isFixed:Int = False)
		
		Self._interpolate(0)
		Self.setRenderState()
		
		' Render
		If Self._image And Self.isVisible() Then
			If isFixed Or camera = Null Or Self.isIgnoringCamera() Then
				DrawImage Self._image, Self._tweenedPosition._xPos, Self._tweenedPosition._yPos, Self._frame
			Else
				DrawImage Self._image, Self._tweenedPosition._xPos - camera.getX(), Self._tweenedPosition._yPos - camera.getY(), Self._frame
			EndIf
		End If
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------
	
	Function Create:ImageSprite(image:TImage, xPos:Int, yPos:Int)
		Local this:ImageSprite = New ImageSprite
		this.setImage(image)
		this.setPosition(xPos, yPos)
		Return this
	End Function
	
	Method New()
		Self._animationRunner = New SpriteAnimationHandler
		Self._animationRunner.setParent(Self)
	End Method
	
End Type
