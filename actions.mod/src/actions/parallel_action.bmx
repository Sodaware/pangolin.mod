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
Import "../core/exceptions.bmx"

''' <summary>
''' Execute multiple actions simultaneously.
'''
''' A `ParallelAction` runs multiple `BackgroundActions` at the same time. Each
''' action in the group is executed on every update until all actions are
''' complete.
'''
''' The `ParallelAction` itself is finished only when all child actions have
''' finished executing.
''' </summary>
Type ParallelAction Extends BackgroundAction
	Field _actions:BackgroundAction[] = new BackgroundAction[0]

	Method countActions:Int()
		Return Self._actions.Length
	End Method


	' ----------------------------------------------------------------------
	' -- Adding Items
	' ----------------------------------------------------------------------

	''' <summary>
	''' Add an action.
	'''
	''' This adds an action to the end of the list, autoloads its services,
	''' and runs its `init` function.
	'''
	''' Will raise an exception if the action is empty.
	''' </summary>
	''' <param name="action">The action to add.</param>
	''' <return>The added action.</return>
	Method add:BackgroundAction(action:BackgroundAction)
		' Check action is valid.
		If action = Null Then Throw New Pangolin_Actions_NullActionException

		' Inject the game kernel into the action and autoload.
		action.setKernel(Self.getKernel())
		If Self.getKernel() <> Null Then action.autoloadServices()

		' Initialize action.
		action.init()

		' Add to the back of the actions array.
		Self._actions = Self._actions[..Self._actions.Length + 1]
		Self._actions[Self._actions.Length - 1] = action

		Return action
	End Method


	' ----------------------------------------------------------------------
	' -- Updating
	' ----------------------------------------------------------------------

	Method execute(delta:Float)
		' Do nothing if this group contains no actions.
		If Self._actions.Length = 0 Then Return

		Local finishedCount:Int = 0

		For Local action:BackgroundAction = EachIn Self._actions
			If action.isFinished() = False Then
				action.execute(delta)
			Else
				finishedCount:+ 1
			End If
		Next

		If Self.countActions() = finishedCount Then
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

	Function Create:ParallelAction()
		Local this:ParallelAction = New ParallelAction

		Return this
	End Function

End Type
