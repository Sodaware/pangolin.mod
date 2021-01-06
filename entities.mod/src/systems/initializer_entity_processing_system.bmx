' ------------------------------------------------------------------------------
' -- systems/initializer_entity_processing_system.bmx
' --
' -- Base system that processes entities when they are added to the world. Use
' -- these for loading assets and setting up initial data.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


''' <summary>
''' Base system that processes entities when they are added to the world.
'''
''' Use these for loading assets and setting up initial data.
''' </summary>
Type InitializerEntityProcessingSystem Extends InitializerEntitySystem Abstract

	Method processEntity(e:Entity) Abstract

	Method process()

	End Method

	Method added(e:Entity)
		Self.processEntity(e)
	End Method

	Method processEntities(entities:EntityBag)

	End Method

End Type
