' ------------------------------------------------------------------------------
' -- src/actions/callback_action.bmx
' --
' -- Wrap an EventHandler (also known as a callback) inside an action.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.events

Import "../core/background_action.bmx"

Type CallbackAction Extends BackgroundAction
	Field _callback:EventHandler


	' ------------------------------------------------------------
	' -- Start and Finish
	' ------------------------------------------------------------

	Method onStart()
		Self._callback.call(Null)
		Self.finished()
	End Method


	' ------------------------------------------------------------
	' -- Main Execution
	' ------------------------------------------------------------

	Method execute(delta:Float)
		' Does nothing - execution happens in `onStart`.
	End Method


	' ------------------------------------------------------------
	' -- Construction / Destruction
	' ------------------------------------------------------------

	Function Create:CallbackAction(action:EventHandler)
		Local this:CallbackAction = New CallbackAction

		this._callback = action

		Return this
	End Function

End Type
