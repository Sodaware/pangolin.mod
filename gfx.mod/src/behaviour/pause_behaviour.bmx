' ------------------------------------------------------------------------------
' -- sprite_behaviours/pause_behaviour.bmx
' --
' -- Simple sprite animation object that waits for a number of milliseconds to
' -- elapse before finishing.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "sprite_behaviour.bmx"


Type PauseBehaviour Extends SpriteBehaviour

	Field _limit:Float
	Field _timeRemaining:Float


	' --------------------------------------------------
	' -- Inherited functions (update/draw)
	' --------------------------------------------------
	
	Method update(delta:Float)
		Self._timeRemaining :- delta
		If Self._timeRemaining <= 0 Then Self.finished()
	End Method


	' --------------------------------------------------
	' -- Construction
	' --------------------------------------------------

	''' <summary>Create a new PauseAnimation object.</summary>
	''' <param name="time">The time in milliseconds for this object to pause.</param>
	Function Create:PauseBehaviour(time:Float)

		Local this:PauseBehaviour = New PauseBehaviour

		this._limit         = time
		this._timeRemaining = time

		Return this

	End Function

End Type
