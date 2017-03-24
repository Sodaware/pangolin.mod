' ------------------------------------------------------------------------------
' -- src/renderer/sprite_animation/sequential_animation.bmx
' --
' -- Execute sprite animations one after another.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.linkedlist
Import "abstract_sprite_animation.bmx"

Type SequentialSpriteAnimation Extends AbstractSpriteAnimation

	Field RepeatLimit:Int	= 0
	
	Field m_Animations:TList
	Field m_RepeatCount:Int
	Field m_CurrentSprite:AbstractSpriteAnimation
	Field m_AnimPosition:Int	= -1
	
	' ----- Constructors
	 
	Function Create:SequentialSpriteAnimation(repeatLimit:Int = 0)
		Local this:SequentialSpriteAnimation	= New SequentialSpriteAnimation
		
		this.RepeatLimit	= repeatLimit
		
		Return this
	End Function
	
	Method New()
		Self.m_Animations	= New TList
	End Method
	
	' ----- API Methods
	
	Method Add(anim:AbstractSpriteanimation)
	
		Self.m_Animations.AddLast(anim)
		
		' If this is the first addition, set it as the current sprite
		If Self.m_Animations.Count() = 1 Then
			Self.m_CurrentSprite	= anim
			Self.m_AnimPosition		= 0
		End If
		
	End Method
	
	' ----- Interface Implementation

	Method Update()

		' Check we have something to display
		If Self.m_Animations.Count() = 0 Then Return

		' Update the current animation
		Self.m_CurrentSprite.Update()
		
		' If the current animation has completely finished, 
		If Self.m_CurrentSprite.Finished Then
		
			' Check if there's another anim
			Self.m_AnimPosition:+ 1
			
			If Self.m_AnimPosition < Self.m_Animations.Count() Then
				
				' If there is, set to current anim
				Self.m_CurrentSprite = AbstractSpriteAnimation(Self.m_Animations.ValueAtIndex(Self.m_AnimPosition))
			
			Else
				
				' Check repeat count 
				If Self.m_RepeatCount < Self.RepeatLimit Then
					
					' If we need to repeat, inc counter and repeat (set current anim to first)
					Self.m_RepeatCount:+ 1
					Self.m_AnimPosition		= 0
					Self.m_CurrentSprite 	= AbstractSpriteAnimation(Self.m_Animations.ValueAtIndex(Self.m_AnimPosition))
					
				Else
					Self.Finished			= True				
				End If
			
			EndIf

		EndIf




	End Method
	

End Type
