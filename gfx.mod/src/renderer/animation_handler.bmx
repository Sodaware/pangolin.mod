' ------------------------------------------------------------------------------
' -- src/renderer/animation_handler.bmx
' --
' -- Wraps animation playback functionality.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Import brl.linkedlist

Import "sprite_animation/abstract_sprite_animation.bmx"

SuperStrict


Type AnimationHandler
	
	Field _currentAnim:AbstractSpriteAnimation
	Field _parent:Object
	
	Field _animations:TList
	
	Field _repeatLimit:Int
	Field _isFinished:Byte
	
	Field _repeatCount:Int
	Field _animPosition:Int
	
	
	' ------------------------------------------------------------
	' -- Getters
	' ------------------------------------------------------------
	
	Method isFinished:Byte()
		Return Self._isFinished
	End Method
	
	Method add(anim:AbstractSpriteAnimation)
	
		anim.setParent(Self._parent)
		Self._animations.AddLast(anim)
		
		' If this is the first addition, set it as the current sprite
		If Self._animations.Count() = 1 Then
			Self._currentAnim	= anim
			Self._animPosition	= 0
		End If
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Updating things
	' ------------------------------------------------------------
	
	Method update(delta:Float)
		
		' Check we should be running
		If Self.isFinished() Then Return

		' Check we have something to display
		If Self._animations.Count() = 0 Then Return
		If Self._currentAnim = Null Then Throw "Invalid sprite in AnimationHandler.update()"
		
		' Update the current animation
		Self._currentAnim.update(delta)
		
		' If the current animation has completely finished, 
		If Self._currentAnim.isFinished() Then
		
			' Check if there's another anim
			Self._animPosition:+ 1
			If Self._animPosition < Self._animations.Count() Then
				
				' If there is, set to current anim
				Self._currentAnim = AbstractSpriteAnimation(Self._animations.ValueAtIndex(Self._animPosition))
			
			Else
				
				' Check repeat count 
				If Self._repeatCount < Self._repeatLimit Then
					
					' If we need to repeat, inc counter and repeat (set current anim to first)
					Self._repeatCount:+ 1
					Self._animPosition		= 0
					Self._currentAnim 	= AbstractSpriteAnimation(Self._animations.ValueAtIndex(Self._animPosition))
					
				Else
					
					Self._isFinished = True
				
				End If
			
			EndIf

		EndIf

	End Method

		
	' ------------------------------------------------------------
	' -- Construction / Destruction
	' ------------------------------------------------------------
	 
	Function Create:AnimationHandler(parent:Object)
		Local this:AnimationHandler	= New AnimationHandler
		this._parent = parent
		Return this
	End Function
	
	Method New()
		Self._animations	= New TList
		Self._repeatLimit	= 0
		Self._animPosition	= -1
	End Method
		
End Type
