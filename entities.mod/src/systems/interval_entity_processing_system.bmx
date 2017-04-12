' ------------------------------------------------------------------------------
' -- systems/interval_entity_processing_system.bmx
' -- 
' -- Processes entities at specific entities. Most systems will run every 
' -- frame, so this is a way to execute actions less often.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type IntervalEntityProcessingSystem Extends IntervalEntitySystem Abstract

	Method processEntity(e:Entity) Abstract
	
	Method processEntities(entities:EntityBag)
		For Local e:Entity = EachIn entities
			Self.processEntity(e)
		Next
	End Method

End Type
