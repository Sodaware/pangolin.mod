' ------------------------------------------------------------------------------
' -- src/actions/parallel_action.bmx
' --
' -- Execute several actions in parallel. Finished when all actions are done.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.linkedlist

Import "../core/background_action.bmx"

Type ParallelAction Extends BackgroundAction

	Field _actions:TList
	Field _actionCount:Int = 0


	' ----------------------------------------------------------------------
	' -- Adding Items
	' ----------------------------------------------------------------------

	Method add:BackgroundAction(action:BackgroundAction)
		' Inject the game kernel into the action and autoload.
		action.setKernel(Self.getKernel())
		action.autoloadServices()
		action.init()

		Self._actions.AddLast(action)
		Self._actionCount :+ 1

		Return action
	End Method


	' ----------------------------------------------------------------------
	' -- Updating
	' ----------------------------------------------------------------------

	Method execute(delta:Float)

		Super.execute(delta)

		' Do nothing if this group contains no actions.
		If Self._actionCount = 0 Then Return

		Local finishedCount:Int = 0

		For Local action:BackgroundAction = EachIn Self._actions
			If action.isFinished() = False Then
				action.execute(delta)
			Else
				finishedCount:+ 1
			End If
		Next

		If Self._actionCount = finishedCount Then
			Self._isFinished = True
		End If

	End Method


	' ----------------------------------------------------------------------
	' -- Hooks
	' ----------------------------------------------------------------------

	Method onStart()
		Super.onStart()
		For Local action:BackgroundAction = EachIn Self._actions
			action.onStart()
		Next
	End Method

	Method onFinish()
		Super.onFinish()
		For Local action:BackgroundAction = EachIn Self._actions
			action.onFinish()
		Next
	End Method


	' ----------------------------------------------------------------------
	' -- Construction & Destruction
	' ----------------------------------------------------------------------

	Function Create:ParallelAction(actions:BackgroundAction[] = Null)
		Local this:ParallelAction = New ParallelAction

		If actions <> Null Then
			For Local action:BackgroundAction = EachIn actions
				this.add(action)
			Next
		End If

		Return this
	End Function

	Method New()
		Self._actions = New TList
	End Method

End Type
