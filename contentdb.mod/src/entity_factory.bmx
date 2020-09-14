' ------------------------------------------------------------------------------
' -- src/entity_factory.bmx
' --
' -- Factory class for creating game objects and their components using a
' -- template.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.reflection
Import brl.map

Import pangolin.entities

Import "entity_template.bmx"

Type EntityFactory

	''' <summary>Static collection of Component Name => TTypeID. Use "name" metadata.</summary>
	Global _typeIdLookup:TMap

	''' <summary>Entity World.</summary>
	Global _world:World

	''' <summary>Set the world that created entities will live in.</summary>
	Function setWorld(worldInstance:World)
		Self._world = worldInstance
	End Function


	' ------------------------------------------------------------
	' -- Object Creation
	' ------------------------------------------------------------

	''' <summary>Spawns a new object from a template.</summary>
	''' <param name="template">The template to use for the new object.</param>
	''' <param name="tag">Optional tag for this game object.</param>
	''' <return>The created object, or null if there was an error.</return>
	Function spawnObject:Entity(template:EntityTemplate, tag:String = "")

		' Check inputs and configuration.
		If template = Null Then Return Null
		If Self._world = Null Then
			Throw "EntityFactory::spawnObject - No world set (use EntityFactory::setWorld first)"
		End If

		' Create new object.
		Local objectInstance:Entity = EntityFactory._world.createEntity()
		objectInstance.setGroup(tag)
		objectInstance.setTag(tag)

		' Add components based on each sub-template.
		For Local component:ComponentTemplate = EachIn template.getComponentTemplates()

			' Create the component from the template.
			Local componentInstance:EntityComponent = EntityFactory._createComponent(component)

			' Add the component if valid.
			If componentInstance Then
				objectInstance.addComponent(componentInstance)
			EndIf

		Next

		Return objectInstance

	End Function

	''' <summary>Creates a collection of entities from a list of entity templates.</summary>
	''' <param name="entityList">A list of EntityTemplates to create.</param>
	''' <param name="refreshEntities">If true, entities will be refreshed.</param>
	''' <returns>An array of Entity objects created from the templates.</returns>
	Function spawnEntities:Entity[](entityList:TList, refreshEntities:Byte = False)

		Local entities:Entity[entityList.Count()]
		Local i:Int = 0

		For Local template:EntityTemplate = EachIn entityList
			entities[i] = EntityFactory.spawnObject(template, template.getIdentifier())
			If refreshEntities Then	entities[i].refresh()
			i:+ 1
		Next

		Return entities

	End Function


	' ------------------------------------------------------------
	' -- Internal component creation functions
	' ------------------------------------------------------------

	''' <summary>Creates a component instance based on a template.</summary>
	''' <param name="template">The template to instantiate.</param>
	''' <returns>The newly created component.</returns>
	Function _createComponent:EntityComponent(template:ComponentTemplate)

		' Check inputs
		If template = Null Then Throw "Cannot create component from invalid template"

		' Get the Blitz type for this component and create.
		Local typeDef:TTypeId = EntityFactory._getTemplateTypeId(template)
		If typeDef = Null Then
			DebugLog "Component '" + template.getSchemaName() + "' not found"
			Return Null
		EndIf

		' Create the component instance.
		Local instance:EntityComponent = EntityComponent(typedef.NewObject())
		Local initMethod:TMethod       = typeDef.FindMethod("intializeFromTemplate")

		' Allow instance to set itself up.
		instance.beforeCreate()

		' Call an initialize method (if present)
		If initMethod Then
			initMethod.Invoke(instance, [template])
		Else
			' Alert developer to implement createComponentTemplate method
			DebugLog "No ~qintializeFromTemplate~q method found for '" + typeDef.Name() + "', falling back to reflection"
			Self._createComponentFromTypeId(instance, typeDef, template)
		End If

		' Call any post-setup actions.
		instance.afterCreate()

		Return instance

	End Function

	''' <summary>Creates a component using reflection.</summary>
	Function _createComponentFromTypeId:EntityComponent(instance:EntityComponent, typeDef:TTypeId, template:ComponentTemplate)

		' Set each field manually.
		Local fieldList:TList = template.getSchema().getFields()
		For Local fieldData:ComponentField = EachIn fieldList
			Local fieldDefinition:TField = typeDef.FindField(fieldData.getName())

			' Ignore field if it doesn't exist or is internal / private.
			If fieldDefinition = Null Or fieldDefinition.Name().StartsWith("m_") Or fieldDefinition.Name().StartsWith("_") Then
				Continue
			End If

			' Set the value based on the data type.
			Select fieldData.getType()
				' TODO: Also count "1" as true?
				Case "bool"
					fieldDefinition.set(instance, String(Lower(template.getFieldValue(fieldData.getName())) = "true"))

				Case "string_list"
					fieldDefinition.set(instance, template.getRawField(fieldData.getName()))

				Default
					fieldDefinition.set(instance, template.getFieldValue(fieldData.getName()))

			End Select

		Next

		' Set internal fields.
		For Local internalField:String = EachIn template.getSchema().getInternals()
			Local fieldDefinition:TField = typeDef.FindField(internalField)

			If fieldDefinition <> Null Then
				fieldDefinition.set(instance, template.getRawField(internalField))
			EndIf
		Next

		Return instance

	End Function


	' ------------------------------------------------------------
	' -- Internal type id helpers
	' ------------------------------------------------------------

	''' <summary>Get the BlitzMax Type data for a component template.</summary>
	Function _getTemplateTypeId:TTypeId(template:ComponentTemplate)
		If EntityFactory._TypeIdLookup = Null Then EntityFactory._setup()

		Return TTypeId(EntityFactory._TypeIdLookup.ValueForKey(template.getSchemaName()))
	End Function


	' ------------------------------------------------------------
	' -- Internal lookup initialisation
	' ------------------------------------------------------------

	''' <summary>Creates a map of component name to ttypeid objects.</summary>
	Function _setup()

		' TODO: Use the ComponentTypeManager here?
		EntityFactory._TypeIdLookup = New TMap

		Local baseType:TTypeId = TTypeId.ForName("EntityComponent")
		For Local childType:TTypeId = EachIn baseType.DerivedTypes()
			If childType.MetaData("name") Then EntityFactory._TypeIdLookup.Insert(childType.MetaData("name"), childType)
		Next

	End Function

End Type
