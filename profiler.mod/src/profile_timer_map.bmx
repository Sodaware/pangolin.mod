' ------------------------------------------------------------------------------
' -- pangolin.profiler - src/profile_timer_map.bmx
' --
' -- Strongly-typed map of names to ProfileTimer objects.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.map

Import "profile_timer.bmx"

Type ProfileTimerMap Extends TMap
	
	Method getTimer:ProfileTimer(name:String)
		Return ProfileTimer(Self.ValueForKey(name))
	End Method
	
End Type