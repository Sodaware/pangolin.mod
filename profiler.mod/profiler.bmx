' ------------------------------------------------------------------------------
' -- pangolin.profiler - profiler.bmx
' --
' -- Very lightweight code profiler for Pangolin.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- This library is free software; you can redistribute it and/or modify
' -- it under the terms of the GNU Lesser General Public License as
' -- published by the Free Software Foundation; either version 3 of the
' -- License, or (at your option) any later version.
' --
' -- This library is distributed in the hope that it will be useful,
' -- but WITHOUT ANY WARRANTY; without even the implied warranty of
' -- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
' -- GNU Lesser General Public License for more details.
' -- 
' -- You should have received a copy of the GNU Lesser General Public
' -- License along with this library (see the file COPYING for more
' -- details); If not, see <http://www.gnu.org/licenses/>.
' ------------------------------------------------------------------------------


SuperStrict

Module pangolin.profiler
ModuleInfo "Pangolin.Profiler - Lightweight profiler class."

Import brl.filesystem

Import "src/profile_timer.bmx"
Import "src/profile_timer_map.bmx"


''' <summary>
''' Profiler used by Pangolin. It can be called globally using `enableProfiler`
''' and the `startProfile` and `stopProfile` functions.
''' </summary>
Type PangolinProfiler

	''' <summary>
	''' Global profiler instance. Not created until `enableProfiler` is called.
	''' </summary>
	Global g_Profiler:PangolinProfiler

	''' <summary>Profile timers lookup.</summary>
	Field _timers:ProfileTimerMap
	
	
	' ------------------------------------------------------------
	' -- Enabling and disabling the profiler
	' ------------------------------------------------------------
	
	Function enableProfiler()
		PangolinProfiler.g_Profiler = New PangolinProfiler
	End Function
	
	Function disableProfiler()
		PangolinProfiler.g_Profiler = Null
	End Function

	' TODO: Allow a formatted to be passed in (so we can use XML, text, csv etc)
	Function saveLog(fileName:String)
		If PangolinProfiler.g_Profiler Then
			PangolinProfiler.g_Profiler.save(fileName)
		End If
	End Function


	' ------------------------------------------------------------
	' -- Global profiling
	' ------------------------------------------------------------
	
	Function startProfile(name:String)
		If PangolinProfiler.g_Profiler Then
			PangolinProfiler.g_Profiler.StartTimer(name)
		End If
	End Function

	Function stopProfile(name:String)
		If PangolinProfiler.g_Profiler Then
			PangolinProfiler.g_Profiler.StopTimer(name)
		End If
	End Function
	

	' ------------------------------------------------------------
	' -- Profiling
	' ------------------------------------------------------------
	
	''' <summary>Starts a debug timer.</summary>
	''' <param name="timerName">The name of the timer to start. Case sensitive.</param>	
	Method startTimer(timerName:String)
		
		Local timer:ProfileTimer = Self._timers.getTimer(timerName)
		If timer = Null Then
			timer = ProfileTimer.Create(timerName)
			Self._timers.Insert(timerName, timer)
		End If
		
		timer.start()
	
	End Method

	''' <summary>Stops a debug timer.</summary>
	''' <param name="timerName">The name of the timer to stop. Case sensitive.</param>	
	Method stopTimer(timerName:String)
		
		Local timer:ProfileTimer = Self._timers.getTimer(timerName)
		
		If timer = Null Then	' Error - can't find timer to stop
			Throw "Timer " + timerName + " not found"
		EndIf
		
		timer.Stop()
	
	End Method


	' ------------------------------------------------------------
	' -- Saving
	' ------------------------------------------------------------

	Method save(fileName:String)

		Local fileOut:TStream = WriteFile(filename)

		For Local timer:ProfileTimer = EachIn Self._timers.Values()
			fileOut.WriteLine(timer._name + " " + timer._calls + " " + timer._totalTime + " " + (timer._totalTime / timer._calls))
		Next

		fileOut.Close()

	End Method


	' ------------------------------------------------------------
	' -- Construction / Destruction
	' ------------------------------------------------------------

	Method New()
		Self._timers = New ProfileTimerMap
	End Method

End Type
