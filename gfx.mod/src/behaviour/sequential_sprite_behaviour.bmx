' ------------------------------------------------------------------------------
' -- sprite_animations/sequential_sprite_animation.bmx
' --
' -- Execute several animations in a sequence.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.linkedlist
Import "sprite_behaviour.bmx"

Type SequentialSpriteBehaviour Extends SpriteBehaviour

	Field RepeatLimit:Int	= 0
	
	Field m_Animations:TList
	Field m_RepeatCount:Int
	Field m_CurrentSprite:AbstractSpriteBehaviour
	Field m_AnimPosition:Int	= -1
	
	' ----- Constructors
	 
	Function Create:SequentialSpriteBehaviour(repeatLimit:Int = 0)
		Local this:SequentialSpriteBehaviour	= New SequentialSpriteBehaviour
		
		this.RepeatLimit	= repeatLimit
		
		Return this
	End Function
	
	Method New()
		Self.m_Animations	= New TList
	End Method
	
	' ----- API Methods
	
	Method Add(anim:AbstractSpriteBehaviour)
	
		Self.m_Animations.AddLast(anim)
		
		' If this is the first addition, set it as the current sprite
		If Self.m_Animations.Count() = 1 Then
			Self.m_CurrentSprite	= anim
			Self.m_AnimPosition		= 0
		End If
		
	End Method
	
	' ----- Interface Implementation

	Method update(delta:Float)

		' Check we have something to display
		If Self.m_Animations.Count() = 0 Then Return

		' Update the current animation
		Self.m_CurrentSprite.update(delta)
		
		' If the current animation has completely finished, 
		If Self.m_CurrentSprite.isFinished() Then
		
			' Check if there's another anim
			Self.m_AnimPosition:+ 1
			
			If Self.m_AnimPosition < Self.m_Animations.Count() Then
				
				' If there is, set to current anim
				Self.m_CurrentSprite = AbstractSpriteBehaviour(Self.m_Animations.ValueAtIndex(Self.m_AnimPosition))
			
			Else
				
				' Check repeat count 
				If Self.m_RepeatCount < Self.RepeatLimit Then
					
					' If we need to repeat, inc counter and repeat (set current anim to first)
					Self.m_RepeatCount:+ 1
					Self.m_AnimPosition		= 0
					Self.m_CurrentSprite 	= AbstractSpriteBehaviour(Self.m_Animations.ValueAtIndex(Self.m_AnimPosition))
					
				Else
					Self._isFinished = True				
				End If
			
			EndIf

		EndIf

	End Method
	
End Type
