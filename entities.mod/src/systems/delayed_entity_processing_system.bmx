' ------------------------------------------------------------------------------
' -- src/systems/delated_entity_processing_system.bmx
' --
' -- Processes entities after a set amount of time has elapsed.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type DelayedEntityProcessingSystem Extends DelayedEntitySystem Abstract

	Field _accumulatedDelta:Float

	Method _processEntities(entities:EntityBag, accumulatedDelta:Float) Final
		Self._accumulatedDelta = accumulatedDelta
		For Local e:Entity = EachIn entities
			Self.processEntity(e)
		Next
	End Method

End Type