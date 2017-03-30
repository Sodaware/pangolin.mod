' ------------------------------------------------------------------------------
' -- renderers/tile_animation_handler.bmx
' -- 
' -- Internal object for managing single tile animations.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Type TileAnimationHandler
		
	Field _frames:Int[]
	Field _frameTimers:Int[]
	
	Field _currentFrame:Int
	Field _nextFrame:Int
	Field _framePos:Int = 0
	
	Field _elapsedFrameTime:Float		'''< Current time elapsed in the frame
	Field _animationFrameTime:Float		'''< Current max frame time

	Field _animDirection:Int
	
	Field _playing:Int
	Field _loopCount:Int
	Field _loopPosition:Int
	
	Method countFrames:Int()
		Return Self._frames.Length
	End Method
	
	Method countTimers:Int()
		Return Self._frameTimers.Length
	End Method
	
	Method update(delta:Float)
		
		' Do nothing if not playing
		If 0 = Self._frames.length Then Return
		If False = Self._playing Then Return
		
		' Update current frame time
		Self._elapsedFrameTime:+ delta
		
		If Self._elapsedFrameTime >= Self._animationFrameTime Then
					
			' Move to the next frame
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
			
			' Update the frame and timer
			Self._currentFrame       = Self._frames[Self._framePos]
			Self._animationFrameTime = Self._frameTimers[Self._framePos]
			
			Self._elapsedFrameTime   = Self._elapsedFrameTime - Self._animationFrameTime

			
		End If
		
		
		
	End Method
	
	Method New()
		
	End Method
	
	Method play()
		Self._playing            = True
		Self._framePos           = 0
		Self._currentFrame       = Self._frames[Self._framePos]
		Self._animationFrameTime = Self._frameTimers[Self._framePos]
		
		Self._loopCount = -1
		Self._loopPosition = 0
		Rem
	
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
		End rem
	End Method
	
End Type
