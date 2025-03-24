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

Import pangolin.resources

Import "../abstract_sprite_request.bmx"
Include "../sprite_animation_handler.bmx"

''' <summary>
''' A renderable image sprite.
'''
''' Renders a BlitzMax `TImage` and contains helpers for changing frames and
''' running frame-based animations.
'''
''' If you want to draw an image on the screen, this is probably what you want.
''' <summary>
Type ImageSprite Extends AbstractSpriteRequest

	Field _frame:Int                                '''< Current frame.
	Field _image:TImage                             '''< Image strip to display.
	Field _animationRunner:SpriteAnimationHandler   '''< Handles the animation.
	Field _animation:AnimationResource              '''< The animation for this sprite.

	' ------------------------------------------------------------
	' -- Animation Checking
	' ------------------------------------------------------------

	''' <summary>Check if this sprite is currently playing an animation.</summary>
	''' <returns>True if an animation is currently playing, false if not.</returns>
	Method isAnimationRunning:Byte()
		Return Self._animationRunner And Self._animationRunner.isPlaying()
	End Method

	''' <summary>Check if this sprite's animation is finished.</summary>
	''' <returns>True if animation is finished, false if not.</returns>
	Method isAnimationFinished:Byte()
		Return Not Self.isAnimationRunning()
	End Method

	' ------------------------------------------------------------
	' -- Setting image / frame
	' ------------------------------------------------------------

	''' <summary>Set the image to display.</summary>
	''' <param name="image">The TImage to display.</param>
	''' <param name="frame">Optional frame offset to use. Defaults to 0.</param>
	Method setImage(image:TImage, frame:Int = 0)
		Self._image = image
		Self._frame = frame
	End Method

	''' <summary>Set the image frame to display.</summary>
	''' <param name="frame">The frame offset to use. Leave blank to reset it to 0.</param>
	Method setFrame(frame:Int = 0)
		Self._frame = frame
	End Method

	''' <summary>Increase the displayed frame offset.</summary>
	''' <param name="increaseBy">Optional value to increase by. Defaults to 1.</param>
	Method increaseFrame(increaseBy:Int = 1)
		Self._frame :+ increaseBy
	End Method

	''' <summary>Decrease the displayed frame offset.</summary>
	''' <param name="decreaseBy">Optional value to decrease by. Defaults to 1.</param>
	Method decreaseeFrame(decreaseBy:Int)
		Self._frame :- decreaseBy
	End Method

	''' <summary>
	''' Set the animation to run.
	'''
	''' Does not play the animation, only sets it.
	''' </summary>
	''' <param name="animation">The AnimationResource to use.</param>
	Method setAnimation(animation:AnimationResource)
		Self._animation = animation
	End Method

	' ------------------------------------------------------------
	' -- Animation Helpers
	' ------------------------------------------------------------

	''' <summary>
	''' Play an animation.
	'''
	''' The animation must be set via `setAnimation` before this is called.
	''' </summary>
	''' <param name="animationName">The name of the animation to play.</param>
	''' <param name="speed">Optional speed modifier. Higher values will play it faster, lower values will be slower.</param>
	Method play(animationName:String, speed:Float = 1.0)
		Self._animationRunner.play(animationName)
	End Method

	''' <summary>Stop the playing animation.</summary>
	Method stopAnimation()
		Self._animationRunner.stop()
	End Method

	''' <summary>Set the frame time for the animation runner.</summary>
	Method setFrameTime(frameTime:Int)
		' TODO: Don't set the private field - use a setter.
		Self._animationRunner._animationFrameTime = frameTime
	End Method

	' ------------------------------------------------------------
	' -- Rendering
	' ------------------------------------------------------------

	''' <summary>Update the sprite and animation animations.</summary>
	Method update(delta:Float)
		Super.update(delta)
		Self._animationRunner.update(delta)
	End Method

	Method render(delta:Double, camera:AbstractRenderCamera, isFixed:Byte = False)
		Self._interpolate(0)

		' Do nothing if not visible.
		If Not Self._image Or Not Self.isVisible() Then Return

		' Set the render state.
		Self.setRenderState()

		' Render
		If isFixed Or camera = Null Or Self.isIgnoringCamera() Then
			DrawImage Self._image, Self._tweenedPosition._xPos, Self._tweenedPosition._yPos, Self._frame
		Else
			DrawImage Self._image, Self._tweenedPosition._xPos - camera.getX(), Self._tweenedPosition._yPos - camera.getY(), Self._frame
		EndIf

		' Reset the render state.
		' TODO: Reset everything in a method.
		brl.max2d.SetRotation(0)
	End Method


	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------

	''' <summary>Create a new ImageSprite instance.</summary>
	''' <param name="image">The TImage to display.</param>
	''' <param name="xPos">The initial X position.</param>
	''' <param name="yPos">The initial Y position.</param>
	''' <param name="frame">Optional frame number to display. Defaults to 0.</param>
	''' <returns>A new ImageSprite instance.</returns>
	Function Create:ImageSprite(image:TImage, xPos:Float, yPos:Float, frame:Int = 0)
		Local this:ImageSprite = New ImageSprite

		this.setImage(image)
		this.setPosition(xPos, yPos)
		this.setFrame(frame)

		Return this
	End Function

	Method New()
		Self._animationRunner = New SpriteAnimationHandler
		Self._animationRunner.setParent(Self)
	End Method

End Type
