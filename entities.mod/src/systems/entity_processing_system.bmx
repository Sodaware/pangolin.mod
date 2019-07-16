' ------------------------------------------------------------------------------
' -- src/systems/entity_processing_system.bmx
' --
' -- Base system that processes entities.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


''' <summary>Base system that processes entities.</summary>
Type EntityProcessingSystem Extends EntitySystem

	Method processEntity(e:Entity) Abstract

	Method processEntities(entities:EntityBag) Final
		For Local e:Entity = EachIn entities
			Self.processEntity(e)
		Next
	End Method

	''' <summary>Run every loop by default.</summary>
	Method checkProcessing:Byte()
		Return True
	End Method

End Type
