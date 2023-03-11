' ------------------------------------------------------------------------------
' -- src/soda_content_db_serializer.bmx
' --
' -- Allows the loading of the content database using the SODA file format.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.ContentDb

Import sodaware.file_soda

Type SodaContentDbSerializer Extends ContentDbSerializer

	' ------------------------------------------------------------
	' -- File check
	' ------------------------------------------------------------

	''' <summary>Check if FILENAME can be loaded. Checks the extension.</summary>
	Method canLoad:Byte(fileName:String)
		Return (ExtractExt(fileName) = "soda")
	End Method


	' ------------------------------------------------------------
	' -- Load the content
	' ------------------------------------------------------------

	''' <summary>Loads content into a ContentDb object from any readable stream or filename.</summary>
	''' <param name="db">The content database to load into.</param>
	''' <param name="url">The stream of file to load from.</param>
	Method load(db:ContentDb, url:Object)

		' Check inputs.
		If db = Null Then Throw "Attempted to load an invalid database"

		' Load the file.
		Local file:SodaFile = SodaFile.Load(url)
		If file = Null Then RuntimeError("Couldn't load " + url.ToString())

		' Find template nodes.
		If file.GetNodes("[t:template]") = Null Then Return
		For Local grp:SodaGroup = EachIn TList(file.GetNodes("[t:template]"))

			' Create template.
			Local template:EntityTemplate = EntityTemplate.Create( ..
				grp.GetIdentifier(), ..
				grp.getFieldString("doc"), ..
				grp.getFieldString("specializes") ..
			)

			template.setCategory(grp.getFieldString("category_name"))

			' Load each child component in this template.
			Local components:TList = grp.GetChildren()
			For Local childGroup:SodaGroup = EachIn components

				' Get the schema + create component template (if schema found).
				Local templateSchema:ComponentSchema = db.GetComponentSchema(childGroup.GetIdentifier())

				' Skip invalid schemas.
				If templateSchema = Null Then Continue

				' Create new component template to load into.
				Local componentTemplate:ComponentTemplate = ComponentTemplate.Create(templateSchema)

				' Check for child groups (internal fields / arrays).
				If childGroup.countChildren() > 0 Then

					' Load each child group into an array.
					For Local t:SodaGroup = EachIn childGroup.GetChildren()

						' Set the property.
						If componentTemplate.schemaHasInternal(t.GetIdentifier()) Then
							componentTemplate._setFieldValueObject(t.GetIdentifier(), t)
						End If

					Next
				EndIf

				' Set field values.
				For Local key:String = EachIn childGroup._fields.Keys()
					componentTemplate._setFieldValue(key, String(childGroup.GetField(key)))
				Next

				' Add it to the object template.
				template.AddComponentTemplate(componentTemplate)

			Next

			db.RegisterGameObjectTemplate(template)

		Next

	End Method

	''' <summary>
	''' Load one or more entity definitions into the content database.
	'''
	''' An entity definition is a specialized template that can be used to spawn
	''' a configured `Entity` object. These are usually used to create things
	''' like level entities from a definition file instead of by hand.
	''' </summary>
	Method loadEntities:TList(db:ContentDb, url:Object)
		' TODO: Refactor this to reduce duplicate code from `load` method

		Local entities:TList = New TList

		' Check inputs
		If db = Null Then Throw "Attempted to load an invalid database"

		Local fileIn:TStream = ReadFile(url)
		Local file:SodaFile  = SodaFile.Load(fileIn)

		If file = Null Then RuntimeError("Couldn't load " + url.ToString())
		If file.GetNodes("[t:entity]") = Null Then Return Null

		' Load all entity template nodes.
		For Local grp:SodaGroup = EachIn TList(file.GetNodes("[t:entity]"))

			' Get the parent type - required for this part.
			Local parent:String = String(grp.getField("specializes"))
			If parent = Null Then Throw "Cannot create an entity without a valid parent type"

			' Fetch the parent template.
			Local parentTemplate:EntityTemplate = db.getObjectTemplate(parent)
			If parentTemplate = Null Then Throw "Could not spawn entity from undefined template: " + parent

			' Clone the parent template.
			Local template:EntityTemplate = parentTemplate.clone()

			' Set new details.
			template._name     = grp.GetIdentifier()
			template._inherits = parent

			' Load each child component in this template.
			Local components:TList = grp.GetChildren()
			For Local childGroup:SodaGroup = EachIn components

				' Get the schema + create component template (if schema found).
				Local templateSchema:ComponentSchema = db.GetComponentSchema(childGroup.GetIdentifier())

				' Skip invalid schemas.
				If templateSchema = Null Then Continue

				' Create new component template to load into.
				Local component:ComponentTemplate = template.GetComponentTemplate(templateSchema.GetName())

				' If template doesn't exist in leaf, create it.
				If component = Null Then
					component = ComponentTemplate.Create(templateSchema)
					template.addComponentTemplate(component)
				EndIf

				' Set field values.
				For Local key:String = EachIn childGroup._fields.Keys()
					component._setFieldValueObject(key, childGroup.GetField(key))
				Next

			Next

			' Add to list.
			entities.AddLast(template)

		Next

		Return entities

	End Method

	Method save(db:ContentDb, url:Object)
		Throw "Not yet implemented!"
	End Method

End Type
