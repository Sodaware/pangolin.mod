' ------------------------------------------------------------------------------
' -- src/renderer/sprite_animation_handler.bmx
' -- 
' -- Runs frame-based animations.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type SpriteAnimationHandler
		
	Field _frames:Int[]
	Field _animation:Object
	Field _currentFrame:Int
	Field _nextFrame:Int
	Field _currentAnim:String 
	Field _framePos:Int = 0
	
	Field _frameTime:Float
	Field _animDirection:Int
	
	Field _parent:ImageSprite
	Field _playing:Int
	Field _loopCount:Int
	Field _loopPosition:Int
	
	Field _animationFrameTime:Float
	
	Method isPlaying:Byte()
		return Self._playing
	End Method
	
	Method update(delta:Float)
	
		If Self._parent._animation = Null Then Return
		If Self._frames.length     = 0 Then Return
		If Self._playing           = False Then Return
	
		Self._frameTime:+ delta
		
		If Self._frameTime >= Self._animationFrameTime Then
			
			Self._frameTime = Self._frameTime - Self._animationFrameTime
			
			' [todo] - Clean this up
			
			Self._framePos:+ 1
			
			If Self._framePos >= Self._frames.length Then
				' Check if loop is done
				Self._loopPosition:+ 1
				If Self._loopCount <> - 1 Then
					If Self._loopPosition >= Self._loopCount Then  
						Self._playing = False
						Self._framePos:- 1
					Else
						Self._framePos = 0
					EndIf
				Else
					Self._framePos = 0
				EndIf
			EndIf
			
			Self._currentFrame = Self._frames[Self._framePos]
			
		End If
		
		Self._parent.setFrame(Self._currentFrame)
	End Method
	

	Method setParent(parent:ImageSprite)
		Self._parent = parent
	End Method
	
	Method New()
		
	End Method
	
	Method stop()
		Self._playing = False
	End Method
	
	Method play(name:String)
		
		If name = Self._currentAnim Then Return
		
		' Reset the animation
		Self._currentAnim        = name
		Self._frames             = Self._parent._animation.getFrameset(name)
		Self._framePos           = 0
		Self._currentFrame       = Self._frames[Self._framePos]
		Self._loopCount          = Self._parent._animation._loopCount
		Self._animationFrameTime = Self._parent._animation._frameTime
		Self._loopPosition       = 0
		Self._playing            = True
		
	End Method
	
End Type
