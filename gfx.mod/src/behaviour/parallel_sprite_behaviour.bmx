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

	Field _animations:TList
	Field _animCount:Int = 0
	

	' ----------------------------------------------------------------------
	' -- Adding Items
	' ----------------------------------------------------------------------
	
	Method add(anim:AbstractSpriteBehaviour)
		Self._animations.AddLast(anim)
		Self._animCount :+ 1
	End Method


	' ----------------------------------------------------------------------
	' -- Updating
	' ----------------------------------------------------------------------

	Method update(delta:Float)

		' Do nothing if this group contains no animations.
		If Self._animCount = 0 Then Return

		Local finishedCount:Int = 0

		For Local anim:AbstractSpriteBehaviour = EachIn Self._animations
			If anim.isFinished() = False Then
				anim.update(delta)
			Else
				finishedCount:+ 1
			End If
		Next

		If Self._animCount = finishedCount Then
			Self._isFinished = True
		End If

	End Method


	' ----------------------------------------------------------------------
	' -- Hooks
	' ----------------------------------------------------------------------

	Method onStart()
		For Local anim:AbstractSpriteBehaviour = EachIn Self._animations
			anim.onStart()
		Next
	End Method

	Method onFinish()
		For Local anim:AbstractSpriteBehaviour = EachIn Self._animations
			anim.onFinish()
		Next
	End Method


	' ----------------------------------------------------------------------
	' -- Construction & Destruction
	' ----------------------------------------------------------------------

	Function Create:ParallelSpriteBehaviour()
		Local this:ParallelSpriteBehaviour	= New ParallelSpriteBehaviour
		Return this
	End Function

	Method New()
		Self._animations = New TList
	End Method

End Type
