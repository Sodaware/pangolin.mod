' ------------------------------------------------------------------------------
' -- pangolin.profiler - src/profile_timer.bmx
' --
' -- A single profile timer.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Type ProfileTimer

	Field _name:String
	Field _calls:Int
	Field _totalTime:Int
	
	' Temp variable to hold start time in millisecs
	Field _timerBuffer:Int
	
	Method start()
		
		' Stop the timer if it's already running
		If Self._timerBuffer > 0 Then Self.stop()
		
		' Set the timer buffer.
		Self._timerBuffer = MilliSecs()

	End Method

	Method stop()
		Self._calls:+ 1
		Self._totalTime = Self._totalTime + (MilliSecs() - Self._timerBuffer)
		Self._timerBuffer = 0
	End Method

	Function Create:ProfileTimer(name:String)
		Local this:ProfileTimer = New ProfileTimer
		this._name = Name
		Return this
	End Function

End Type
