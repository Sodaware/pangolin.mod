' ------------------------------------------------------------------------------
' -- src/actions/sequential_action.bmx
' --
' -- Execute one or more actions in a sequence.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.linkedlist

Import "../core/background_action.bmx"

Type SequentialAction Extends BackgroundAction

	Field RepeatLimit:Int = 0

	' -- Internals
	Field _actions:TList
	Field _actionCount:Int
	Field _repeatCount:Int
	Field _currentAction:BackgroundAction
	Field _actionPosition:Int


	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------

	Method add:BackgroundAction(action:BackgroundAction)
		' Inject the game kernel into the action and autoload.
		action.setKernel(Self.getKernel())
		action.autoloadServices()
		action.init()

		Self._actions.AddLast(action)
		Self._actionCount :+ 1

		' If this is the first addition, set it as the current action.
		If Self._actionCount = 1 Then
			Self._currentAction  = action
			Self._actionPosition = 0
		End If

		Return action

	End Method


	' ----------------------------------------------------------------------
	' -- Hooks
	' ----------------------------------------------------------------------

	Method onStart()
		Super.onStart()
		Self._currentAction.onStart()
	End Method


	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------

	Method execute(delta:Float)
		' Check we actions to run.
		If Self._actionCount = 0 Then Return

		' Update the current action.
		Self._currentAction.execute(delta)

		' If the current action has completely finished, either
		' move to the next one or finish this list completely.
		If Self._currentAction.isFinished() Then

			' Run hooks.
			Self._currentAction.onFinish()

			' Check if there's another action.
			Self._actionPosition :+ 1

			If Self._actionPosition < Self._actionCount Then

				' If there is, set to current action
				Self._moveToNextAction()

			Else

				' Sequence has ended - check repeat count
				If Self._repeatCount < Self.RepeatLimit Or self.RepeatLimit = -1 Then

					' If we need to repeat, inc counter and repeat (set current action to first)
					Self._repeatCount   :+ 1
					Self._actionPosition  = 0
					Self._moveToNextAction()

				Else
					Self.finished()
				End If

			End If

		End If

	End Method

	Method _moveToNextAction()
		Self._currentAction = BackgroundAction(Self._actions.ValueAtIndex(Self._actionPosition))
		Self._currentAction.onStart()
	End Method


	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------

	Function Create:SequentialAction(repeatLimit:Int = 0)
		Local this:SequentialAction = New SequentialAction

		this.repeatLimit = repeatLimit

		Return this
	End Function

	Method New()
		Self._actions         = New TList
		Self._actionPosition = -1
	End Method

End Type
