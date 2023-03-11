' ------------------------------------------------------------------------------
' -- Pangolin.Entities -- entity.bmx
' --
' -- A basic entity that exists in a game world. Consists of two identifiers:
' --	* ID        - An id that may be re-used when the entity is destroyed
' --	* UniqueUd  - A unique ID that will not be re-used.
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
	Field _id:Int                       '''< ID of the object that may be re-used when the entity is destroyed.
	Field _uniqueId:Long                '''< An ID that is unique to this object.

	Field _typeBits:BitStorage          '''< A list of component types this entity is interested in.
	Field _systemBits:BitStorage        '''< A list of systems that this entity is processed by.

	Field _world:World                  '''< The world this entity belongs to.
	Field _entityManager:EntityManager  '''< The manager for the world.

	' This is a shortcut.
	Field _components:ObjectBag         '''< Quick lookup of components this entity has.


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
		Return Self._world
	End Method

	''' <summary>Get the entity manager this entity is managed by.</summary>
	Method getEntityManager:EntityManager()
		Return Self._entityManager
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
	Method getTypeBits:BitStorage()
		Return Self._typeBits
	End Method

	''' <summary>Get the System Bits for this entity.</summary>
	Method getSystemBits:BitStorage()
		Return Self._systemBits
	End Method

	''' <summary>Does this entity have a specific type bit attached?</summary>
	Method hasTypeBit:Byte(bit:Byte)
		Return Self._typeBits.hasBit(bit)
	End Method

	''' <summary>Does this entity have a specific system bit attached?</summary>
	Method hasSystemBit:Byte(bit:Byte)
		Return Self._systemBits.hasBit(bit)
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
	Method addTypeBit:Entity(bit:Byte)
		Self._typeBits.setBit(bit)

		Return Self
	End Method

	''' <summary>Remove a type bit from the entity.</summary>
	Method removeTypeBit:Entity(bit:Byte)
		Self._typeBits.clearBit(bit)

		Return Self
	End Method

	''' <summary>Remove a type bit from the entity.</summary>
	Method resetTypeBits:Entity()
		Self._typeBits.clearBits()

		Return Self
	End Method

	''' <summary>Add a system bit to the entity.</summary>
	Method addSystemBit:Entity(bit:Byte)
		Self._systemBits.setBit(bit)

		Return Self
	End Method

	''' <summary>Remove a system bit from the entity.</summary>
	Method removeSystemBit:Entity(bit:Byte)
		Self._systemBits.clearBit(bit)

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
	''' Called when an entity has had components changed.
	'''
	''' Refreshing an entity causes the world to update the system relationships.
	''' </summary>
	Method refresh()
		Self._world.refreshEntity(Self)
	End Method

	''' <summary>Clear this entity's systems and components.</summary>
	Method reset()
		Self._systemBits.clearBits()
		Self._typeBits.clearBits()

		' Remove all components (may need to clear from a manager).
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
		Return Self._typeBits.hasBit(t.getBit())
	End Method

	''' <summary>
	''' Check if the entity has a component type and throw an exception if not.
	''' </summary>
	''' <param name="t">The ComponentType to check for.</param>
	Method requireComponent(t:ComponentType)
		If Self.hasComponent(t) Then Return

		Throw MissingEntityComponentException.Create(Self, t)
	End Method

	''' <summary>Get a component from the entity by its type.</summary>
	Method getComponent:EntityComponent(t:ComponentType)
		Return Self._entityManager.getComponent(Self, t)
	End Method

	''' <summary>Get a component type by its meta name.</summary>
	Method getComponentByName:EntityComponent(name:String, required:Byte = False)
		' Get type with this meta-data.
		Local ct:ComponentType = ComponentTypeManager.getTypeForMetaName(name)
		If ct = Null Then Return Null

		Return Self.getComponent(ct)
	End Method


	' ------------------------------------------------------------
	' -- Component Field Access
	' ------------------------------------------------------------

	''' <summary>
	''' Directly set a component field value.
	'''
	''' This is slower and riskier than setting via the component instance, but
	''' is a useful shortcut if you know what you're doing.
	'''
	''' Be warned that it will throw runtime errors if tying to access invalid
	''' components or fields.
	''' </summary>
	''' <param name="componentName">The component name to modify.</param>
	''' <param name="fieldName">The field to modify.</param>
	''' <param name="value">The new value of the field.</param>
	''' <return>The entity instance.</return>
	Method setComponentField:Entity(componentName:String, fieldName:String, value:Object)
		Local c:EntityComponent = Self.getComponentByName(componentName)
		Local t:TTypeId         = TTypeId.ForObject(c)
		Local f:TField          = t.findField(fieldName)

		f.set(c, value)

		Return Self
	End Method

	''' <summary>
	''' Directly get a component field value.
	'''
	''' Like `setComponentField`, this is slower and riskier than getting via the
	''' component instance. It also needs to be converted to whatever data type
	''' you need.
	'''
	''' Be warned that it will throw runtime errors if tying to access invalid
	''' components or fields.
	''' </summary>
	''' <param name="componentName">The component name to get.</param>
	''' <param name="fieldName">The field to get.</param>
	''' <return>The component field value.</return>
	Method getComponentField:Object(componentName:String, fieldName:String)
		Local c:EntityComponent = Self.getComponentByName(componentName)
		Local t:TTypeId         = TTypeId.ForObject(c)
		Local f:TField          = t.findField(fieldName)

		Return f.get(c)
	End Method

	''' <summary>
	''' Directly get a component field value and cast to an integer.
	''' </summary>
	''' <seealso cref="getComponentField">Wrapper for getComponentField.</seealso>
	''' <param name="componentName">The component name to get.</param>
	''' <param name="fieldName">The field to get.</param>
	''' <return>The component field value.</return>
	Method getComponentFieldI:Int(componentName:String, fieldName:String)
		Return Int(String(Self.getComponentField(componentName, fieldName)))
	End Method


	' ------------------------------------------------------------
	' -- Group management
	' ------------------------------------------------------------

	''' <summary>Get the group name for Entity.</summary>
	''' <seealso cref="GroupManager">See GroupManager for more information on groups.</seealso>
	Method getGroup:String()
		Return Self._world.getGroupManager().getGroupOf(Self)
	End Method

	''' <summary>Set the group name for Entity.</summary>
	''' <seealso cref="GroupManager">See GroupManager for more information on groups.</seealso>
	Method setGroup:Entity(groupName:String)
		Self._world.getGroupManager().set(groupName, Self)

		Return Self
	End Method


	' ------------------------------------------------------------
	' -- Debug Helpers
	' ------------------------------------------------------------

	Method dumpComponents()
		DebugLog "Entity " + Self.getId() + " [" + Self.getTag() + "]"

		DebugLog "Attached components:"
		For Local c:EntityComponent = EachIn Self.getComponents()
			Local ct:TTypeId = TTypeId.ForObject(c)
			DebugLog "  - " + ct.name()

			For Local f:TField = EachIn ct.EnumFields()
				DebugLog "    - " + f.Name() + ":" + f.TypeId().name() + " => " + String(f.get(c))
			Next
		Next
	End Method


	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------

	''' <summary>Create an Entity.</summary>
	''' <description>Do NOT call this directly. Use World.create instead.</description>
	''' <param name="w">The World this entity will belong to.</param>
	''' <param name="id">The identifier of the new entity.</param>
	''' <return>The newly created entity.</return>
	Function Create:Entity(w:World, id:Int)
		If w = Null Then Throw New InvalidWorldInstanceException

		Local this:Entity = New Entity

		this._world         = w
		this._entityManager = w.getEntityManager()
		this._id            = id

		Return this
	End Function

	Method New()
		Self._components = ObjectBag.Create()
		Self._typeBits   = New BitStorage
		Self._systemBits = New BitStorage
	End Method

End Type
