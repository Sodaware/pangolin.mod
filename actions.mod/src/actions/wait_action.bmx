' ------------------------------------------------------------------------------
' -- src/actions/wait_action.bmx
' --
' -- Wait for a set amount of time.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../core/background_action.bmx"

Type WaitAction Extends BackgroundAction
	Field _timer:Float


	' ------------------------------------------------------------
	' -- Main Execution
	' ------------------------------------------------------------

	Method execute(delta:Float)
		Self._timer :- delta

		If Self._timer <= 0 Then Self.finished()
	End Method


	' ------------------------------------------------------------
	' -- Construction / Destruction
	' ------------------------------------------------------------

	Function Create:WaitAction(time:Float)
		Local this:WaitAction = New WaitAction

		this._timer = time

		Return this
	End Function

End Type
