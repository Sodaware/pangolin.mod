' ------------------------------------------------------------------------------
' -- systems/interval_entity_system.bmx
' --
' -- Base system for processing actions at specific intervals. Most systems
' -- will run every frame, so this is a way to execute actions less often.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type IntervalEntitySystem Extends EntitySystem Abstract

	Field _timeSinceLastExecution:Float
	Field _interval:Float

	Method setInterval(interval:Float)
		Self._interval = interval
	End Method

	Method checkProcessing:Byte()
		Self._timeSinceLastExecution :+ Self._world.getDelta()
		If Self._timeSinceLastExecution >= Self._interval Then
			Self._timeSinceLastExecution :- Self._interval
			return True;
		EndIf
		Return False
	End Method

End Type
