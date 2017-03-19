' ------------------------------------------------------------------------------
' -- Pangolin.Entities -- entity.bmx
' -- 
' -- A basic entity that exists in a game world. Consists of two identifiers:
' --	o ID		- An id that may be re-used when the entity is destroyed
' --	o UniqueUd	- A unique ID that will not be re-used.
' -- 
' -- Entities must be created via world.createEntity so that their identifiers
' -- are set correctly.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


''' <summary>
''' A basic entity that exists in a game world. Consists of two identifiers:
'''   * ID : An id that may be re-used when the entity is destroyed
'''   * UniqueId : A unique ID that will not be re-used.
'''
''' Entities may also have a `Group` and `Tag`. 
''' 
''' Groups can contain more than one entity, but an entity may only belong to
''' a single group at a time.
''' 
''' Tags are unique string identifiers. An entity can only have a single tag,
''' and that Tag must be unique to the entity.
''' 
''' Entities must be created via world.createEntity so that their identifiers
''' are set correctly.
''' </summary>
Type Entity
	
	' -- Object information
	Field _id:Int						'''< ID of the object that may be re-used when the entity is destroyed
	Field _uniqueId:Long				'''< An ID that is unique to this object
	
	Field _typeBits:Long				'''< A list of component types this entity is interested in
	Field _systemBits:Long				'''< A list of systems that this entity is processed by
		
	Field _world:World					'''< The world this entity belongs to
	Field _entityManager:EntityManager	'''< The manager for the world
	
	' This is a shortcut
	Field _components:ObjectBag			'''< Quick lookup of components this entity has
	
	
	' ------------------------------------------------------------
	' -- Getting Object Info
	' ------------------------------------------------------------
	
	''' <summary>Check if the entity is active.</summary>
	Method isActive:Byte()
		Return Self._entityManager.isActive(Self._id)
	End Method
	
	''' <summary>Get CACHED list of components from the entity.</summary>
	Method getComponents:ObjectBag()
		Return Self._components
	End Method

	''' <summary>Get the World instance this entity belongs to.</summary>
	Method getWorld:World()
		return Self._world
	End Method

	''' <summary>Get the entity manager this entity is managed by.</summary>
	Method getEntityManager:EntityManager()
		return Self._entityManager
	End Method
	
	''' <summary>Get the ID of this entity.</summary>
	''' <return>Entity ID.</return>
	Method getId:Int()
		Return Self._id
	End Method

	''' <summary>Get the Unique ID for this entity.</summary>
	Method getUniqueId:Long()
		Return Self._uniqueId
	End Method
	
	''' <summary>Get the Type Bits for this entity.</summary>
	''' <description>
	''' Type Bits are a quick way to look up component types. Each component 
	''' type has a unique bit assigned to it (1, 2, 4 etc). These can then be 
	''' set in a Long and queried quickly using binary functions (AND, OR etc).
	''' </description>
	Method getTypeBits:Long()
		Return Self._typeBits
	End Method
	
	''' <summary>Get the System Bits for this entity.</summary>
	''' <description>
	''' System Bits are a quick way to look up systems. Each system has a unique
	''' bit assigned to it (1, 2, 4 etc). These can then be set in a Long and 
	''' queried quickly using binary functions (AND, OR etc).
	''' </description>
	Method getSystemBits:Long()
		Return Self._systemBits
	End Method
	
	
	' ------------------------------------------------------------
	' -- Setting object information 
	' ------------------------------------------------------------
	
	''' <summary>Set the unique ID for this Entity.</summary>
	Method setUniqueId:Entity(uniqueId:Long)
		Self._uniqueId = uniqueId
		Return Self
	End Method
	
	
	' ------------------------------------------------------------
	' -- ComponentType and System information
	' ------------------------------------------------------------
	
	''' <summary>Add a type bit to the entity.</summary>
	Method addTypeBit:Entity(bit:Long)
		Self._typeBits = Self._typeBits | bit
		Return Self
	End Method
	
	''' <summary>
	''' Set all type bits for the entity. This will overwrite any 
	''' existing type bit information.
	''' </summary>
	Method setTypeBits:Entity(typeBits:Long)
		Self._typeBits = typeBits
		Return Self
	End Method
	
	''' <summary>Remove a type bit from the entity.</summary>
	Method removeTypeBit:Entity(bit:Long)
		Self._typeBits = Self._typeBits & ~bit
		Return Self
	End Method
	
	''' <summary>Add a system bit to the entity.</summary>
	Method addSystemBit:Entity(bit:Long)
		Self._systemBits =Self._systemBits | bit
		Return Self
	End Method
	
	''' <summary>
	''' Set all system bits for the entity. This will overwrite any 
	''' existing system bit information.
	''' </summary>
	Method setSystemBits:Entity(systemBits:Long)
		Self._systemBits = systemBits
		Return Self
	End Method
	
	''' <summary>Remove a system bit from the entity.</summary>
	Method removeSystemBit:Entity(bit:Long)
		Self._systemBits = Self._systemBits & ~bit
		Return Self
	End Method
	
	
	' ------------------------------------------------------------
	' -- Tag Management
	' ------------------------------------------------------------

	''' <summary>Set the unique tag for the entity.</summary>
	''' <seealso cref="TagManager">See TagManager for more information on tags.</seealso>
	Method setTag:Entity(tagName:String)
		Self._world.getTagManager().register(tagName, Self)
		Return Self
	End Method

	''' <summary>Get the unique tag for the entity.</summary>
	Method getTag:String()
		Return Self._world.getTagManager().getEntityTag(Self)
	End Method
	
			
	' ------------------------------------------------------------
	' -- Component Management
	' ------------------------------------------------------------
	
	''' <summary>
	''' Called when an entity has had components changed. This causes the
	''' world to update the system relationshops.
	''' </summary>
	Method refresh()
		Self._world.refreshEntity(Self)
	End Method
	
	''' <summary>Clear this entity's systems and components.</summary>
	Method reset()
		Self._systemBits = 0
		Self._typeBits   = 0
		
		' Remove all components (may eed to clear from a manager)
		For Local c:EntityComponent = EachIn Self._components
			Self.removeComponent(c)
		Next
		Self._components.clear()
	End Method

	''' <summary>Add a component to the entity.</summary>
	Method addComponent:Entity(c:EntityComponent)
		Self._entityManager.addComponent(Self, c)
		Return Self
	End Method
	
	''' <summary>Remove a component from the entity.</summary>
	Method removeComponent(c:EntityComponent)
		c.onRemove()
		Self._entityManager.removeComponent(Self, c)
	End Method
	
	''' <summary>Remove a component by its type.</summary>
	Method removeComponentByType(t:ComponentType)
		Local c:EntityComponent = Self.getComponent(t)
		If c = Null Then Return
		Self.removeComponent(c)
	End Method
	
	''' <summary>Remove a component by its lookup name.</summary>
	Method removeComponentByName(typeName:String)
		Local c:EntityComponent = Self.getComponentByName(typeName)
		If c = Null Then Return
		Self.removeComponent(c)
	End Method
	
	''' <summary>Check if the entity has a component type.</summary>
	Method hasComponent:Byte(t:ComponentType)
		Return (Self._typeBits & t.getBit() > 0)
	End Method

	
	''' <summary>Get a component from the entity by its type.</summary>
	Method getComponent:EntityComponent(t:ComponentType)
		Return Self._entityManager.getComponent(Self, t)
	End Method
	
	''' <summary>Get a component type by its meta name.</summary>
	Method getComponentByName:EntityComponent(name:String, required:Byte = False)
		
		' Get type with this meta-data
		Local ct:ComponentType = ComponentTypeManager.getTypeForMetaName(name)
		If ct = Null Then Return Null
		
		Return Self.getComponent(ct)
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Group management
	' ------------------------------------------------------------
	
	''' <summary>Set the group name for Entity.</summary>
	''' <seealso cref="GroupManager">See GroupManager for more information on groups.</seealso>
	Method setGroup(groupName:String)
		Self._world.getGroupManager().set(groupName, Self)
	End Method
	
	
	' ------------------------------------------------------------
	' -- Debug Helpers
	' ------------------------------------------------------------
	
	Method dumpComponents()
		DebugLog "Entity[" + Self.getTag() + "]"
		DebugLog "Available components:"
		For Local c:EntityComponent = EachIn Self.getComponents()
			DebugLog "  - " + TTypeId.ForObject(c).Name()
		Next
	End Method
	
	
	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------
	
	''' <summary>Do NOT call this directly. Use World.create instead.</summary>
	Function Create:Entity(w:World, id:Int)
	
		If w = Null Then Throw "Entity must belong to a valid World instance"
		
		Local this:Entity = New Entity
		this._world = w
		this._entityManager = w.getEntityManager()
		this._id = id
		Return this
	
	End Function
	
	Method New()
		Self._components = ObjectBag.Create()
	End Method
	
End Type
