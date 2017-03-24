' ------------------------------------------------------------------------------
' -- sprite_animations/parallel_sprite_animation.bmx
' --
' -- Join multiple sprite animations together to execute at the same time.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.linkedlist
Import "sprite_behaviour.bmx"

Type ParallelSpriteBehaviour Extends SpriteBehaviour

	Field m_Animations:TList
	
	' ----- Constructors
	 
	Function Create:ParallelSpriteBehaviour()
		Local this:ParallelSpriteBehaviour	= New ParallelSpriteBehaviour
		Return this
	End Function
	
	Method New()
		Self.m_Animations	= New TList
	End Method
	
	' ----- API Methods
	
	Method Add(anim:AbstractSpriteBehaviour)
		Self.m_Animations.AddLast(anim)
	End Method
	
	' ----- Interface Implementation

	Method update(delta:Float)

		' Check we have something to display
		If Self.m_Animations.Count() = 0 Then Return

		Local finishedCount:Int = 0
		
		For Local anim:AbstractSpriteBehaviour = EachIn Self.m_Animations
			If anim.isFinished() = False Then
				anim.update(delta)
			Else
				finishedCount:+ 1
			End If
		Next

		If Self.m_Animations.Count() = finishedCount Then
			Self._isFinished = True
		End If

	End Method
	

End Type