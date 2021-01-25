' ------------------------------------------------------------------------------
' -- src/simple_timer.bmx
' --
' -- A simple timer object that calls one (or more) hooked callbacks every
' -- tick. Must be manually updated every frame.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2018 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "hooks.bmx"

Type SimpleTimer

	Field _isRunning:Byte
	Field _time:Float

	Field _hooks:Hooks

	Field _currentTime:Float
	Field _delay:Float
	Field _repeatLimit:Int
	Field _repeatCount:Int


	' ------------------------------------------------------------
	' -- Adding Handlers
	' ------------------------------------------------------------

	Method whenTicks:SimpleTimer(callback:EventHandler)
		Self._hooks.add("on_tick", callback)

		Return Self
	End Method


	' ------------------------------------------------------------
	' -- Construction
	' ------------------------------------------------------------


	Method isRunning:Byte()
		Return Self._isRunning
	End Method

	Method isExpired:Byte()
		Return (Self._time < 0)
	End Method

	Method stop()
		Self._isRunning = False
	End Method

	Method start()
		Self._isRunning = True
	End Method

	Method set(limit:Float)
		Self._time = limit
	End Method


	' ------------------------------------------------------------
	' -- Construction
	' ------------------------------------------------------------

	Method update(delta:Float)

		If Self._isRunning = False Then Return

		Self._currentTime :- delta

		If Self._currentTime < 0 Then
			Self._currentTime :+ Self._delay
			Self._repeatCount :+ 1

			' Notify hooks.
			Self._hooks.sendEvent(GameEvent.CreateEvent("on_tick", Self))

			If Self._repeatCount = Self._repeatLimit Then
				Self._isRunning = False
			End If
		End If

	End Method


	' ------------------------------------------------------------
	' -- Construction
	' ------------------------------------------------------------

	Function Create:SimpleTimer(delayTime:Float, repeatCount:Int)
		Local this:SimpleTimer = New SimpleTimer
		this._currentTime = delayTime
		this._delay = delayTime
		this._repeatLimit = repeatCount
		Return this
	End Function

	Method New()
		Self._hooks = Hooks.create(["on_tick"])
	End Method

End Type
