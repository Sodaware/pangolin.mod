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

	Field _limit:Int
	Field _expireTime:Int
	
	
	' --------------------------------------------------
	' -- Constructors
	' --------------------------------------------------
	
	''' <summary>Create a new PauseAnimation object.</summary>
	''' <param name="time">The time in milliseconds for this object to pause.</param>
	Function Create:PauseBehaviour(time:Int)
		
		Local this:PauseBehaviour	= New PauseBehaviour
		this._limit			= time
		this._expireTime	= -1		
		Return this

	End Function

	' --------------------------------------------------
	' -- Inherited functions (update/draw)
	' --------------------------------------------------
	
	Method update(delta:Float)
		If Self._expireTime = -1 Then Self._expireTime	= Self._limit + MilliSecs()
		If MilliSecs() >= Self._expireTime Then Self.finished()
	End Method

End Type
