' ------------------------------------------------------------------------------
' -- systems/sweeper_entity_processing_system.bmx
' -- 
' -- System for processing entities that are about to be deleted.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type SweeperEntityProcessingSystem Extends SweeperEntitySystem Abstract
	
	Method process()
		Self.beforeProcessEntities()
		Self.processEntities(Self._world._deleted)
		Self.afterProcessEntities()
	End Method
	
	Method processEntity(e:Entity) Abstract
	
	Method processEntities(entities:ObjectBag)
		For Local e:Entity = EachIn entities
			Self.processEntity(e)
		Next
	End Method
	
	Method initialize()
		Super.initialize()
	End Method
	
End Type
