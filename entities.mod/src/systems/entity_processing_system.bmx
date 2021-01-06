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

	' ------------------------------------------------------------
	' -- Required methods
	' ------------------------------------------------------------

	Method processEntity(e:Entity) Abstract


	' ------------------------------------------------------------
	' -- Entity processing
	' ------------------------------------------------------------

	Method processEntities(entities:EntityBag) Final
		For Local e:Entity = EachIn entities
			Self.processEntity(e)
		Next
	End Method

	''' <summary>Check if this system can process entities.</summary>
	Method checkProcessing:Byte()
		Return True
	End Method

End Type
