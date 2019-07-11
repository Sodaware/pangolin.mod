' ------------------------------------------------------------------------------
' -- Pangolin.Entities -- entity_component_mapper.bmx
' --
' -- Maps the relationship between an entity and a component. Extend this
' -- and override `get` where a very fast lookup is required.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type EntityComponentMapper

	Field _componentType:ComponentType  '''< The component type mapped.
	Field _em:EntityManager             '''< Entity manager reference.
	Field _classType:TTypeId            '''< TTypeId for the component.


	' ------------------------------------------------------------
	' -- Fetching Components
	' ------------------------------------------------------------

	''' <summary>Get a component for an entity.</summary>
	Method get:EntityComponent(e:Entity)
		Return Self._em.getComponent(e, Self._componentType)
	End Method


	' ------------------------------------------------------------
	' -- Initialization
	' ------------------------------------------------------------

	''' <summary>Map classType to a component type.</summary>
	Method initialize(classType:TTypeId, w:World)
		Self._em			= w.getEntityManager()
		Self._componentType = ComponentTypeManager.getTypeFor(classType)
		Self._classType		= classType
	End Method

End Type
