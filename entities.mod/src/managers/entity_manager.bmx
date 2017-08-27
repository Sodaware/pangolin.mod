' ------------------------------------------------------------------------------
' -- Pangolin.Entities -- entity_manager.bmx
' -- 
' -- Keeps track of all entities within a given World instance. Assigns unique
' -- identifiers and keeps track of components.
' -- 
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type EntityManager Extends BaseManager

	Field _activeEntities:EntityBag   '< Collection of all active entities
	Field _entityPool:EntityBag       '< Pool of entities will be spawned from
	
	Field _nextAvailableId:Int        '< Next available global id
	Field _count:Int                  '< Count of all entities in the World
	
	Field _uniqueEntityId:Long        '< Next available UNIQUE entity id
	Field _totalCreated:Long          '< Total number of entities ever created
	Field _totalRemoved:Long          '< Total number of entities ever removed
	
	' Components
	
	''' <summary>
	''' Maps componentType.id => object bag
	''' Each child bag contains of entity.id => component
	''' </summary>
	Field _componentsByType:ObjectBag
	
	''' <summary>A collection of ComponentType.id => UNORDERED bag of entities.</summary>
	Field _entitiesByComponent:ObjectBag
	
	
	' ------------------------------------------------------------
	' -- Getting Entities and Components
	' ------------------------------------------------------------
	
	''' <summary>Get an entity by its ID.</summary>
	''' <param name="entityId">ID of the entity to retrieve.</param>
	''' <return>The found entity, or null if not found.</return>
	Method getEntity:Entity(entityId:Int)
		Return Self._activeEntities.get(entityId)
	End Method
	
	''' <summary>Get a component with a specific component type from an entity.</summary>
	''' <param name="e">The entity to query.</param>
	''' <param name="t">The ComponentType to search for.</param>
	''' <return>The component instance if set, or null if entity does not have component.</return>
	Method getComponent:EntityComponent(e:Entity, t:ComponentType)
		Local bag:ObjectBag = ObjectBag(Self._componentsByType.get(t.getId()))
		If bag <> Null And e.getId() < bag.getCapacity() Then
			Return EntityComponent(bag.get(e.getId()))
		End If
		Return Null
	End Method
	
	''' <summary>Get all components attached to an entity.</summary>
	''' <param name="e">Entity object to get components for.</param>
	''' <return>ObjectBag of components.</return>
	Method getEntityComponents:ObjectBag(e:Entity)
		Return e.getComponents()
	End Method
	
	''' <summary>
	''' Get an EntityBag containing all entities that have a 
	''' specific component.
	''' </summary>
	''' <param name="t">The type of component to search for.</param>
	''' <return>A collection of entities. May be empty.</return>
	Method getEntitiesWithComponent:EntityBag(t:ComponentType)
		Return EntityBag(Self._entitiesByComponent.get(t.getId()))
	End Method
	
	''' <summary>
	''' Get an EntityBag of all entities that are currently active.
	''' </summary>
	Method getActiveEntities:EntityBag()
		Return Self._activeEntities
	End Method
	
	
	' ------------------------------------------------------------
	' -- Getting Stats
	' ------------------------------------------------------------
		
	''' <summary>
	''' Get the active state of an entity using its ID. Only active entities
	''' are updated.
	''' </summary>
	''' <param name="entityId">ID of the entity to check.</param>
	''' <return>True if entity is active, false if not.</return>
	Method isActive:Byte(entityId:Int)
		Return (Self._activeEntities.get(entityId) <> Null)
	End Method
	
	''' <summary>Get the total number of entities in the World.</summary>
	''' <return>Number of entities.</return>
	Method getEntityCount:Int()
		Return Self._count
	End Method
	
	''' <summary>Get the total number of entities ever created.</summary>
	''' <return>Total number of created entities.</return>
	Method getTotalCreated:Int()
		Return Self._totalCreated
	End Method
	
	''' <summary>Get the total number of entities that have been removed.</summary>
	''' <return>Number of entities that have been removed.</return>	
	Method getTotalRemoved:Int()
		Return Self._totalRemoved
	End Method
	
	
	' ------------------------------------------------------------
	' -- Creating & Removing Entities
	' ------------------------------------------------------------
	
	Method createEntity:Entity()
		
		' Get an entity from the pool. 
		Local e:Entity = Self._getEntityFromPool()
		
		' Set entity values and return
		e.setUniqueId(Self._uniqueEntityId)
		Self._uniqueEntityId:+ 1
		Self._count:+ 1
		Self._totalCreated:+ 1
		
		' Add to list of active entities and return
		Self._activeEntities.set(e.getId(), e)
		
		Return e
		
	End Method
	
	''' <summary>
	''' Remove an entity from the World. This should not be called directly - use 
	''' world.delete instead.
	''' </summary>
	''' <param name="e">The entity to remove.</param>
	Method remove(e:Entity)
	
		' Remove from the list of active entities
		Self._activeEntities.set(e.getId(), Null)
		
		' Remove any component mapping
		e.setTypeBits(0)
		Self.refresh(e)
		Self.removeEntityComponents(e)
		
		' Update internal counters
		Self._count:- 1
		Self._totalRemoved:+ 1
		
		' Completely reset the internals and add it back to the pool
		e.reset()
		Self._addEntityToPool(e)
		
	End Method


	' ------------------------------------------------------------
	' -- Managing Entity Components
	' ------------------------------------------------------------
	
	Method addComponent(e:Entity, c:EntityComponent)

		' TODO: Can probably clean this up a little bit more, but it's better for now.
	
		' Get the component type for this component.
		Local t:ComponentType = ComponentTypeManager.getTypeFor(TTypeId.ForObject(c))
		
		' Get all component instances for this type
		Local components:ObjectBag = Self.getRegisteredComponentsForType(t)
		
		' Map component to the entity.
		components.set(e.getId(), c)
		e.addTypeBit(t.getBit())
		
		' Add to component->entities lookup
		Local entities:EntityBag = Self.getComponentsToEntityLookup(t) 
		entities.add(e)
		
		' Add to entity's internal lookup and map 
		e._components.add(c)
		c._parent = e
		
	End Method
		
	''' <summary>Remove all components from an entity.</summary>
	Method removeEntityComponents(e:Entity)
		For Local c:EntityComponent = EachIn e.getComponents()
			c.onDelete()
			e.removeComponent(c)
		Next
	End Method
	
	''' <summary>Remove a single component from an entity.</summary>
	''' <param name="e">The Entity to remove a component from.</param>
	''' <param name="c">The Component to remove.</param>
	Method removeComponent(e:Entity, c:EntityComponent)
		
		Local typeToRemove:ComponentType = ComponentTypeManager.getTypeFor(TTypeId.ForObject(c));
		Self.removeComponentByType(e, typeToRemove)
		
	End Method
		
	''' <summary>Remove a component from an entity by its ComponentType.</summary>
	Method removeComponentByType(e:Entity, c:ComponentType)
		
		' TODO: Try and improve this method - it's relatively slow has it has to alter 2 object bags
		
		' Remove cached component from this entity
		e._components.removeObject(Self.getComponent(e, c))
		
		' Remove the component type bit
		Local components:ObjectBag = ObjectBag(_componentsByType.get(c.getId()))
		components.set(e.getId(), Null)
		e.removeTypeBit(c.getBit())

		' Remove this entity from the list of entities with a component.
		Local entities:EntityBag = EntityBag(Self._entitiesByComponent.get(c.getId()))
		entities.removeObject(e)	
		
	End Method
		
	''' <summary>IMPORTANT! Call this after components added / deleted.</summary>
	Method refresh(e:Entity)
		Self._world.getSystemManager().refreshEntity(e)
	End Method
	
	Method ensureComponentTypeIsRegistered(t:ComponentType)
		If t.getId() >= Self._componentsByType.getCapacity() Then
			Self._componentsByType.set(t.getId(), Null)
		End If
	End Method

	
	' ------------------------------------------------------------
	' -- Component Access
	' ------------------------------------------------------------
	
	''' <summary>Get a list of all components that are registered for a specific type.</summary>	
	Method getRegisteredComponentsForType:ObjectBag(t:ComponentType)
	
		Self.ensureComponentTypeIsRegistered(t)
		
		Local components:ObjectBag = ObjectBag(Self._componentsByType.get(t.getId()))
		If components = Null Then
			components = ObjectBag.Create()
			Self._componentsByType.set(t.getId(), components)
		End If
		
		Return components
		
	End Method
	
	Method getComponentsToEntityLookup:EntityBag(t:ComponentType)
		Local entities:EntityBag = EntityBag(Self._entitiesByComponent.get(t.getId()))
		If entities = Null Then
			entities = EntityBag.Create()
			Self._entitiesByComponent.set(t.getId(), entities)
		End If
		Return entities
	End Method
	
	
	' ------------------------------------------------------------
	' -- Entity Pool
	' ------------------------------------------------------------
	
	Method _getEntityFromPool:Entity()
		Local e:Entity = Self._entityPool.removeLast()
		If e = Null Then
			e = Entity.Create(Self._world, Self._nextAvailableId)
			Self._nextAvailableId:+ 1
		Else
			e.reset()
		End If
		
		Return e
	End Method
	
	Method _addEntityToPool(e:Entity)
		Self._entityPool.add(e)
	End Method
	
	
	' ------------------------------------------------------------
	' -- Construction
	' ------------------------------------------------------------

	Function Create:EntityManager(w:World)
		Local this:EntityManager = New EntityManager
		this._world = w		
		Return this
	End Function
		
	Method New()
		Self._activeEntities      = New EntityBag
		Self._entityPool          = New EntityBag
		Self._componentsByType    = New ObjectBag
		Self._entitiesByComponent = New ObjectBag
		
		Self._nextAvailableId     = 1
	End Method
	
End Type
