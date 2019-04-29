' ------------------------------------------------------------------------------
' -- services/game_entity_service.bmx
' --
' -- Wraps the World in a service that can be used inside the game kernel.
' -- This is the preferred method if you want systems to access other services
' -- more easily.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type GameEntityService Extends GameService ..
	{ implements = "update" }

	Field _kernelInformation:KernelInformationService    { injectable }
	Field _world:World


	' ------------------------------------------------------------
	' -- Accessing Data
	' ------------------------------------------------------------

	''' <summary>Get the active World for this service.</summary>
	''' <return>Active World instance.</return>
	Method getWorld:World()
		Return Self._world
	End Method

	''' <summary>Get the active GroupManager for the World.</summary>
	''' <return>Active GroupManager object.</return>
	Method getGroupManager:GroupManager()
		Return Self._world.getGroupManager()
	End Method

	''' <summary>Get the active SystemManager for the World.</summary>
	''' <return>Active SystemManager object.</return>
	Method getSystemManager:SystemManager()
		Return Self._world.getSystemManager()
	End Method

	''' <summary>Get the active EntityManager for the World.</summary>
	''' <return>Active EntityManager object.</return>
	Method getEntityManager:EntityManager()
		Return Self._world.getEntityManager()
	End Method

	''' <summary>Get the active TagManager for the World.</summary>
	''' <return>Active TagManager object.</return>
	Method getTagManager:TagManager()
		Return Self._world.getTagManager()
	End Method


	' ------------------------------------------------------------
	' -- Entity Management
	' ------------------------------------------------------------

	''' <summary>Create a new game entity.</summary>
	Method createEntity:Entity()
		Return Self._world.createEntity()
	End Method

	''' <summary>Remove an entity from the world.</summary>
	Method removeEntity(e:Entity)
		Self.getEntityManager().remove(e)
	End Method

	''' <summary>Remove all entities in a collection.</summary>
	''' <param name="entities">A list of all entities to remove.</param>
	Method removeEntities(entities:EntityBag)
		If entities = Null Then Return
		For Local e:Entity = EachIn entities
			Self._world.deleteEntity(e)
		Next
	End Method

	Method removeEntitiesInGroup(groupName:String)
		Self.removeEntities(Self.getGroupManager().getEntities(groupName))
	End Method


	' ------------------------------------------------------------
	' -- Getting Entities
	' ------------------------------------------------------------

	Method getEntityById:Entity(entityId:Int)
		Return Self._world.getEntity(entityId)
	End Method

	Method getEntityByTag:Entity(name:String)
		Return Self.getTagManager().getEntity(name)
	End Method

	Method getActiveEntities:EntityBag()
		Return Self.getEntityManager().getActiveEntities()
	End Method

	Method getEntitiesWithComponentName:EntityBag(name:String)
		Return Self.getEntityManager().getEntitiesWithComponent(ComponentTypeManager.getTypeForMetaName(name))
	End Method

	Method getEntitiesWithComponent:EntityBag(t:ComponentType)
		Return Self.getEntityManager().getEntitiesWithComponent(t)
	End Method

	Method getEntitiesInGroup:EntityBag(groupName:String)
		Return Self.getGroupManager().getEntities(groupName)
	End Method

	Method countEntitiesWithComponent:Int(t:ComponentType)
		Return Self.getEntityManager().countEntitiesWithComponent(t)
	End Method

	' ------------------------------------------------------------
	' -- Getting Component Types
	' ------------------------------------------------------------

	Method getComponentType:ComponentType(name:String)
		Return ComponentTypeManager.getTypeForName(name)
	End Method


	' ------------------------------------------------------------
	' -- Adding Systems
	' ------------------------------------------------------------

	Method addSystem(system:EntitySystem)

		' Set the system in the world
		Self.getSystemManager().setSystem(system)

		' Set the kernel
		system.setKernel(Self._kernelInformation.getKernel())

	End Method

	Method getSystem:EntitySystem(name:String)
		Return Self.getSystemManager().getSystem(TTypeId.ForName(name))
	End Method


	' ------------------------------------------------------------
	' -- System Management
	' ------------------------------------------------------------

	Method initializeSystems()
		Self._world.getSystemManager().initializeAll()
	End Method

	Method stopSystem:byte(name:String)
		Local systemType:TTypeId = TTypeId.ForName(name)
		If Null = systemType Then DebugLog "stopSystem failed - Unknown system type: " + name

		Local system:EntitySystem = Self.getSystemManager().getSystem(systemType)
		If system = Null Then Return False

		system.disableSystem()
		Return True
	End Method

	Method startSystem:Byte(name:String)
		Local systemType:TTypeId = TTypeId.ForName(name)
		If Null = systemType Then DebugLog "startSystem failed - Unknown system type: " + name

		Local system:EntitySystem = Self.getSystemManager().getSystem(systemType)
		If system = Null Then Return False

		system.enableSystem()
		Return True
	End Method


	' ------------------------------------------------------------
	' -- Updates/Rendering
	' ------------------------------------------------------------

	Method update(delta:Float)
		Self._world.execute(delta)
	End Method


	' ------------------------------------------------------------
	' -- Cleanup
	' ------------------------------------------------------------

	Method clearSystems()
		Self._world.getSystemManager().clearSystems()
	End Method

	''' <summary>Remove ALL entities...</summary>
	Method clearEntities()
		For local e:Entity = EachIn self.getEntityManager().getActiveEntities()
			Self._world.deleteEntity(e)
		Next
	End Method


	' ------------------------------------------------------------
	' -- Construction
	' ------------------------------------------------------------

	Method New()
		Self.init()
		Self._world = New World
	End Method

End Type
