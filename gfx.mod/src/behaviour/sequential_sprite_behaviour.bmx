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

	Field RepeatLimit:Int = 0

	' -- Internals
	Field _animations:TList
	Field _animCount:Int
	Field _repeatCount:Int
	Field _currentBehaviour:AbstractSpriteBehaviour
	Field _animPosition:Int


	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------

	Method add:AbstractSpriteBehaviour(anim:AbstractSpriteBehaviour)

		Self._animations.AddLast(anim)
		Self._animCount :+ 1

		' If this is the first addition, set it as the current sprite
		If Self._animCount = 1 Then
			Self._currentBehaviour = anim
			Self._animPosition     = 0
		End If

		Return anim

	End Method


	' ----------------------------------------------------------------------
	' -- Hooks
	' ----------------------------------------------------------------------

	Method onStart()
		Super.onStart()
		Self._currentBehaviour.onStart()
	End Method


	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------

	Method update(delta:Float)

		Super.update(delta)

		' Check we have something to display.
		If Self._animCount = 0 Then Return

		' Update the current animation.
		Self._currentBehaviour.update(delta)

		' If the current animation has completely finished, either
		' move to the next one or finish this anim.
		If Self._currentBehaviour.isFinished() Then

			' Run hooks.
			Self._currentBehaviour.onFinish()

			' Check if there's another anim.
			Self._animPosition :+ 1

			If Self._animPosition < Self._animCount Then

				' If there is, set to current anim
				Self._moveToNextAnimation()

			Else

				' Sequence has ended - check repeat count
				If Self._repeatCount < Self.RepeatLimit Then

					' If we need to repeat, inc counter and repeat (set current anim to first)
					Self._repeatCount   :+ 1
					Self._animPosition  = 0
					Self._moveToNextAnimation()

				Else
					Self.finished()
				End If

			End If

		End If

	End Method

	Method _moveToNextAnimation()
		Self._currentBehaviour = AbstractSpriteBehaviour(Self._animations.ValueAtIndex(Self._animPosition))
		Self._currentBehaviour.onStart()
	End Method


	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------

	Function Create:SequentialSpriteBehaviour(repeatLimit:Int = 0)
		Local this:SequentialSpriteBehaviour = New SequentialSpriteBehaviour

		this.repeatLimit = repeatLimit

		Return this
	End Function

	Method New()
		Self._Animations   = New TList
		Self._animPosition = -1
	End Method

End Type
