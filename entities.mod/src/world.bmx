' ------------------------------------------------------------------------------
' -- Pangolin.Entities -- world.bmx
' -- 
' -- A "World" object contains all entities, their components and the systems 
' -- that manage them. Use this to creates new entities and manage the
' -- relationships between entities and components.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type World
	
	' -- Internal Managers
	Field _managers:TMap
	Field _systemManager:SystemManager
	Field _entityManager:EntityManager
	Field _tagManager:TagManager
	Field _groupManager:GroupManager
	
	' -- Frame delta
	Field _delta:Float
	
	' -- Collection of refreshed / deleted entities
	Field _refreshed:ObjectBag
	Field _deleted:ObjectBag
	
	
	' ------------------------------------------------------------
	' -- Manager Quick Access
	' ------------------------------------------------------------

	''' <summary>Get the active GroupManager for this World.</summary>
	''' <return>Active GroupManager object.</return>
	Method getGroupManager:GroupManager()
		Return Self._groupManager
	End Method
	
	''' <summary>Get the active SystemManager for this World.</summary>
	''' <return>Active SystemManager object.</return>
	Method getSystemManager:SystemManager()
		Return Self._systemManager
	End Method
	
	''' <summary>Get the active EntityManager for this World.</summary>
	''' <return>Active EntityManager object.</return>
	Method getEntityManager:EntityManager()
		Return Self._entityManager
	End Method
	
	''' <summary>Get the active TagManager for this World.</summary>
	''' <return>Active TagManager object.</return>
	Method getTagManager:TagManager()
		Return Self._tagManager
	End Method


	' ------------------------------------------------------------
	' -- Getting/Setting Custom Managers
	' ------------------------------------------------------------
	
	''' <summary>Set a custom manager.</summary>
	''' <param name="manager">The Manager object to be added.</param>
	Method setManager(manager:BaseManager)
		Self._managers.Insert(TTypeId.ForObject(manager), manager)
	End Method
	
	''' <summary>Retrieve a manager of a specified type.</summary>
	''' <param name="managerType">The type of manager to retrieve.</param>
	''' <return>The manager found, or null if non-existant.</return>
	Method getManager:BaseManager(managerType:TTypeId)
		Return BaseManager(Self._managers.ValueForKey(managerType))
	End Method
	
	
	' ------------------------------------------------------------
	' -- Delta Timing
	' ------------------------------------------------------------

	''' <summary>Get the time elapsed since the last game loop.</summary>
	''' <return>Delta time in milliseconds.</return>
	Method getDelta:Float()
		Return Self._delta
	End Method
	
	''' <summary>Set the delta time.</summary>
	''' <param name="delta">Time elapsed since last loop.</param>
	Method setDelta(delta:Float)
		Self._delta = delta
	End Method
	
	
	' ------------------------------------------------------------
	' -- Entity Management
	' ------------------------------------------------------------
	
	''' <summary>Create and return a new entity instance.</summary>
	''' <return>New entity object.</return>
	Method createEntity:Entity()
		Return Self._entityManager.createEntity()
	End Method

	''' <summary>Delete the specified entity from the world.</summary>
	''' <param name="e">The entity instance to remove.</param>
	Method deleteEntity(e:Entity)
		
		' Check object isn't already on the deleted list
		If Self._deleted.contains(e) = False Then
			Self._deleted.add(e)
		End If
		
	End Method
	
	''' <summary>Notifies all systems that an entity has been modified.</summary>
	''' <param name="e">The entity to refresh.</param>
	Method refreshEntity(e:Entity)
		If e <> Null Then Self._refreshed.add(e)
	End Method
	
	''' <summary>Get the entity for a specific ID.</summary>
	''' <param name="entityId">The ID of the entity to retrieve.</param>
	''' <return>The Entity retrieved, or null if not found.</return>
	Method getEntity:Entity(entityId:Int)
		Return Self._entityManager.getEntity(entityId);
	End Method
	
	
	' ------------------------------------------------------------
	' -- Entity Stats
	' ------------------------------------------------------------
	
	''' <summary>Count the number of active entities.</summary>
	Method countEntities:Int()
		Return Self._entityManager.getEntityCount()
	End Method
	
	''' <summary>Count the number of active entities that have a specific component.</summary>
	''' <param name="t">The component type to check for.</param>
	Method countEntitiesWithComponent:Int(t:ComponentType)
		Local entities:ObjectBag = Self._entityManager.getEntitiesWithComponent(t)
		If entities = Null Then Return 0
		Return entities.getSize()
	End Method
	
	
	' ------------------------------------------------------------
	' -- Game loop events
	' ------------------------------------------------------------
	
	''' <summary>
	''' Should be called once every frame. Refreshes entities, clears out
	''' deleted ones and processes all systems.
	''' </summary>
	''' <param name="delta">Delta time since execute last called.</param>	
	Method execute(delta:Float)
		
		' Clear deleted entities
		Self.loopStart()
		
		' Update delta value
		Self.setDelta(delta)
		
		' Run all active systems
		Self.processAllSystems()
		
	End Method
	
	''' <summary>
	''' Call this at the start of every game loop. Refreshes entities and
	''' deletes expired entities.
	''' </summary>
	Method loopStart()
		
		' Clear entities to refresh
		If False = Self._refreshed.isEmpty() Then 
			
			For Local e:Entity = EachIn Self._refreshed
				Self._entityManager.refresh(e)
			Next
			
			Self._refreshed.clear()
			
		EndIf
		
		' Delete entities on the delete pile
		If False = Self._deleted.isEmpty() Then
			
			' Process sweepers
			Self.runSweepers()
			
			' Delete all entities
			For Local e:Entity = EachIn Self._deleted
			
				' Remove entity from groups, tags and entities
				Self._groupManager.remove(e)
				Self._entityManager.remove(e)
				Self._tagManager.remove(e)
				
				' Kill the entity completely (so GC will get it)
				e = Null
				
			Next
			
			Self._deleted.clear()
			
		EndIf
		
	End Method
	
	''' <summary>
	''' Call the "process" method for every system currently 
	''' registered with the World.
	''' </summary>
	Method processAllSystems()
		Self._systemManager.processAll()
	End Method
	
	''' <summary>
	''' Run all sweepers. These are called on entities that
	''' have been deleted before the final deletion takes place.
	''' </summary>
	Method runSweepers()
		Self._systemManager.processSweepers()
	End Method
	
	
	' ------------------------------------------------------------
	' -- Construction
	' ------------------------------------------------------------
	
	Method New()
	
		Self._entityManager = EntityManager.Create(Self)
		Self._systemManager = SystemManager.Create(Self)
		Self._tagManager    = TagManager.Create(Self)
		Self._groupManager  = GroupManager.Create(Self)
		
		Self._refreshed     = New ObjectBag
		Self._deleted       = New ObjectBag
		
		Self._managers      = New TMap

	End Method

End Type
