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


''' <summary>
''' System for processing entities that are about to be deleted.
'''
''' Use these for freeing resources or deleting sprites that are not required
''' once the entity is deleted.
''' </summary>
Type SweeperEntityProcessingSystem Extends SweeperEntitySystem Abstract

	Method processEntity(e:Entity) Abstract

	Method process() Final
		Self.beforeProcessEntities()
		Self.processEntities(Self._world._deleted)
		Self.afterProcessEntities()
	End Method

	Method processEntities(entities:EntityBag) Final
		For Local e:Entity = EachIn entities
			Self.processEntity(e)
		Next
	End Method

End Type
