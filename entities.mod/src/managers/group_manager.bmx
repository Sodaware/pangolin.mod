' ------------------------------------------------------------------------------
' -- managers/group_manager.bmx
' -- 
' -- Manages entity groups. Entities can only belong to a
' -- single group at a time.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


''' <summary>
''' Manages Entity groups. 
''' 
''' Groups can contain multiple entities, but an entity can only belong 
''' to a single group at a time.
''' </summary>
Type GroupManager Extends BaseManager
	
	Field _entitiesByGroup:TMap			'''< A map of Group Name => EntityBag of Entities
	Field _groupByEntity:ObjectBag		'''< A lookup of EntityId => Group Name
	

	' ------------------------------------------------------------
	' -- Querying
	' ------------------------------------------------------------
	
	''' <summary>Get all entities that belong to a group.</summary>
	''' <param name="groupName">The name of the group to fetch entities for.</param>
	Method getEntities:EntityBag(groupName:String)
		Return EntityBag(Self._entitiesByGroup.ValueForKey(groupName))
	End Method
	
	''' <summary>Get an entity's group name.</summary>
	Method getGroupOf:String(e:Entity)
		
		' Do nothing if the entity is not valid
		If e = Null Then Return ""
		
		If e.getId() < Self._groupByEntity.getCapacity() Then
			Local group:Object = Self._groupByEntity.get(e.getId())
			If group = Null Then Return ""
			Return group.toString()
		EndIf
		
		Return ""
		
	End Method
	
	''' <summary>Check if an entity has a group.</summary>
	Method isGrouped:Short(e:Entity)
		Return Self.getGroupOf(e) <> ""
	End Method

	
	' ------------------------------------------------------------
	' -- Adding and Removing Groups
	' ------------------------------------------------------------

	''' <summary>Set an entity's group.</summary>
	''' <param name="groupName">The name of the entity's group.</param>
	''' <param name="e">The entity to set a group for.</param>
	Method set(groupName:String, e:Entity)
	
		' Group name cannot be a blank string
		If groupName = "" Then Return
	
		' Remove entity from its current group
		If Self.isGrouped(e) Then Self.remove(e)
		
		' Get a list of all entities in the group.
		' If there's no existing container, create and add a new one.
		Local entityList:EntityBag = self.getEntities(groupName)
		If entityList = Null Then
			entityList = New EntityBag
			Self._entitiesByGroup.Insert(groupName, entityList)
		End If
		entityList.add(e)
		Self._groupByEntity.set(e.getId(), groupName)
		
	End Method

	''' <summary>Remove an entity from its current group.</summary>
	Method remove(e:Entity)

		' If entity is NOT in a group, don't bother removing
		If False = Self.isGrouped(e) Then Return

		' Get the group name for this entity
		Local group:Object = Self._groupByEntity.get(e.getId())
		
		' Do nothing if entity does not belong to a group.
		If group = Null Then Return
		
		Local groupName:String = group.toString()
		If groupName <> "" Then
				
			Self._groupByEntity.set(e.getId(), Null)
			Local entityList:EntityBag = self.getEntities(groupName)
			If entityList Then
				entityList.removeObject(e)
			End If
			
		End If
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Creation and Destruction
	' ------------------------------------------------------------

	''' <summary>Create a new group manager and assign it to a world.</summary>
	Function Create:GroupManager(w:World)
		Local this:GroupManager = New GroupManager
		this._world = w
		this._entitiesByGroup = New TMap
		this._groupByEntity = New ObjectBag
		Return this
	End Function

End Type
