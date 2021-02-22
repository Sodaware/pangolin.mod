' ------------------------------------------------------------------------------
' -- src/core/action_queue.bmx
' --
' -- Run one or more actions in a sequential queue.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "background_action.bmx"

Type ActionQueue Extends BackgroundAction

	' -- Internals.
	Field _currentAction:BackgroundAction   '''< Current action being run.
	Field _position:Int                     '''< Position in the queue.
	Field _actions:TList = New TList        '''< List of actions to run.


	' ------------------------------------------------------------
	' -- Adding Items
	' ------------------------------------------------------------

	''' <summary>Add a background action to the end of the queue.</summary>
	Method add:ActionQueue(action:BackgroundAction)
		' Inject the game kernel into the action and autoload.
		action.setKernel(Self.getKernel())
		action.autoloadServices()
		action.init()

		Self._actions.AddLast(action)

		Return Self
	End Method


	' ------------------------------------------------------------
	' -- Start and Finish
	' ------------------------------------------------------------

	Method onStart()
		Self._moveToNextAction()
	End Method


	' ------------------------------------------------------------
	' -- Main Execution
	' ------------------------------------------------------------

	Method execute(delta:Float)
		' Do nothing if no queued action.
		If Self._currentAction = Null Then Return

		' Update the action.
		Self._currentAction.execute(delta)

		' If action is finished, move to the next one.
		If Self._currentAction.isFinished() Then
			Self._currentAction.onFinish()
			Self._moveToNextAction()
		End	If
	End Method


	' ------------------------------------------------------------
	' -- Internals
	' ------------------------------------------------------------

	Method _moveToNextAction()
		' Queue is done if there are no more actions.
		If Self._actions.isEmpty() Then
			Self.finished()

			Return
		EndIf

		' Pop the next item off the front of the list.
		Self._currentAction = BackgroundAction(Self._actions.RemoveFirst())
		Self._currentAction.onStart()
	End Method

End Type
