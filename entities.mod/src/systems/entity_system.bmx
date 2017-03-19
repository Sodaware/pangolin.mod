' ------------------------------------------------------------------------------
' -- src/systems/entity_system.bmx
' --
' -- An EntitySystem is used to perform actions on entities that have certain
' -- components attached to them. This is the base class that all other systems
' -- should extend.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


''' <summary>
''' An EntitySystem is used to perform actions on entities. The entities that
''' are processed can be limited to just entities with one or more specific
''' components. For example, a `PlayerInputSystem` that only processes entities
''' with a`PlayerComponent`.
'''
''' This is the base class that all other systems should extend.
''' </summary>
Type EntitySystem Extends KernelAwareInterface Abstract
	
	Field _isEnabled:Byte
	Field _systemBit:Long
	Field _typeFlags:Long
	Field _world:World
	Field _actives:ObjectBag
	
	
	' ------------------------------------------------------------
	' -- Enabling / Disabling
	' ------------------------------------------------------------
	
	''' <summary>Enable this system.</summary>
	Method enableSystem()
		Self._isEnabled = True
		Self.onEnabled()
	End Method

	''' <summary>Disable this system.</summary>
	Method disableSystem()
		Self._isEnabled = False
		Self.onDisabled()
	End Method
	
	''' <summary>Check if the system is enabled.</summary>
	''' <return>True if system enabled, false if not.</return>
	Method isEnabled:Byte()
		Return Self._isEnabled
	End Method
	

	' ------------------------------------------------------------
	' -- Hooks
	' ------------------------------------------------------------
	
	''' <summary>Called when this system has been disabled.</summary>
	Method onDisabled()
	End Method
	
	''' <summary>Called when this system has been enabled.</summary>
	Method onEnabled()
	End Method
	
	''' <summary>
	''' Called when this system is removed from the World.
	''' </summary>
	Method cleanup()
	End Method
	
		
	' ------------------------------------------------------------
	' -- Getters / Setters
	' ------------------------------------------------------------
	
	Method getEntityManager:EntityManager()
		return self._world.getEntityManager()
	End Method
	
	''' <summary>Is this service a sweeper?</summary>
	Method isSweeper:Byte()
		Return False
	End Method
	
	
	' ------------------------------------------------------------
	' -- Processing
	' ------------------------------------------------------------
	
	Method processEntities(entities:ObjectBag) Abstract
	
	Method checkProcessing:Short() Abstract
	
	''' <summary>Called before all entities are processed by this system.</summary>
	Method beforeProcessEntities()
	End Method
	
	''' <summary>Called after all entities are processed by this system.</summary>
	Method afterProcessEntities()
	End Method
	
	' Processes all entities if the system is enabled and can process
	Method process()
		
		If Self._isEnabled And Self.checkProcessing() Then
			Self.beforeProcessEntities()
			Self.processEntities(Self._actives)
			Self.afterProcessEntities()
		End If
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------
	
	Method setSystemBit(bit:Long)
		Self._systemBit = bit
	End Method
	
	Method setWorld(w:World) Final
		Self._world = w
	End Method
	
	Method getWorld:World() Final
		Return Self._world
	End Method
	
	Method initialize()
		Self._autoInjectComponentLookups()
	End Method
	
	''' <summary>Called when an entity has been added to this system's list of interests.</summary>
	Method added(e:Entity)
	
	End Method
	
	''' <summary>Called when an entity has been removed from this system's list of interests.</summary>
	Method removed(e:Entity)
	End Method
	
	Method change(e:Entity)
		
		Local contains:Short = ((Self._systemBit & e.getSystemBits()) = Self._systemBit)
		Local interest:Short = ((Self._typeFlags & e.getTypeBits()) = Self._typeFlags)
		
		If interest And Not(contains) And Self._typeFlags > 0 Then
			Self._actives.add(e)
			e.addSystemBit(Self._systemBit)
			Self.added(e)
		ElseIf (Not(interest) And contains And Self._typeFlags > 0) Then
			Self.remove(e)
		End If
		
	End Method
	
	Method remove(e:Entity)
		Self._actives.removeObject(e)
		e.removeSystemBit(Self._systemBit)
		Self.removed(e)
	End Method
	
	Method registerComponentByName(componentTypeName:String)
		' TODO: Add some error handling here
		Self.registerComponent(TTypeId.ForName(componentTypeName))
	End Method
	
	Method registerComponents(componentTypeList:TTypeId[])
		
		For Local t:TTypeId = EachIn componentTypeList
			Self.registerComponent(t)
		Next
		
	End Method
	
	Method registerComponent(t:TTypeId)
		if t = null then return
		Local ct:ComponentType = ComponentTypeManager.getTypeFor(t)
		Self._typeFlags = Self._typeFlags | ct.getBit()
	End Method

	''
	' Automates registering a system with component types
	Method _autoRegisterComponentTypes()
	
		If Self._typeFlags <> 0 Then Return
		
		Local imp:String = TTypeId.ForObject(Self).MetaData("component_types")
		Local typeList:String[] = imp.Split(",")
		
		For Local typeName:String = EachIn typeList
			typeName = typeName.Trim()
			Self.registerComponentByName(typeName)
		Next
		
	End Method
	
	''' <summary>
	''' Automatically fetches component type lookups for fields that have a 
	''' "component_type" meta field. This is called in the "initialize"
	''' method, so make sure any systems call it.
	''' </summary>
	Method _autoInjectComponentLookups()
		
		Local system:TTypeId = TTypeId.ForObject(Self)
		
		For Local f:TField = EachIn system.Fields()
			If f.MetaData("component_type") <> Null Then
				f.Set(Self, ComponentTypeManager.getTypeForName(f.MetaData("component_type")))
			EndIf
		Next
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Enabling / Disabling
	' ------------------------------------------------------------
	
	Method New()
		Self._actives	= ObjectBag.Create()
		Self._isEnabled	= True
	End Method
	
End Type
