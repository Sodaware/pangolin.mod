' ------------------------------------------------------------------------------
' -- content_db.bmx
' --
' -- The ContentDb class is a database of object templates that can be used
' -- when spawning game entities. Fully-integrated with pangolin.entities.
' --
' -- To actually load content a serializer needs to be imported.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.retro
Import brl.map
Import brl.linkedlist

Import sodaware.file_util
Import sodaware.file_ziphelper
Import pangolin.entities
import pangolin.profiler

' -- Structure
Import "component_schema.bmx"
Import "entity_template.bmx"

' -- Serialization
Include "serializers/content_db_serializer.bmx"
Include "serializers/component_schema_serializer.bmx"
Include "content_db_loader.bmx"


''' <summary>
''' The ContentDb class is a database of entity templates.
'''
''' These templates can be used to spawn `pangolin.entities` objects from a
''' text-based template instead of creating them by hand,
''' </summary>
Type ContentDb

	' -- Maps of templates and schemas.
	Field _objectTemplates:Tmap             '''< Map of TemplateName => ObjectTemplate.
	Field _componentSchemas:Tmap            '''< Map of SchemaName => ComponentSchema.

	' -- Lists of templates and schemas.
	Field _objectTemplateList:TList         '''< List of object templates.
	Field _componentSchemaList:TList        '''< List of component schemas.

	' -- Internal file lists.
	Field _componentFiles:TList
	Field _templateDirectories:TList


	' ----------------------------------------------------------------------
	' -- Add Directories and Archives
	' ----------------------------------------------------------------------

	''' <summary>
	''' Add a directory to the list of directories to scan for templates.
	''' </summary>
	''' <param name="pathName">A valid directory path to add.</param>
	''' <return>Self</return>
	Method addTemplateDirectory:ContentDb(pathName:String)
		' TODO: Check the directory exists (take zip:: etc protocols into account)
		Self._templateDirectories.AddLast(pathName)

		Return Self
	End Method

	''' <summary>Add an archive file to scan for templates.</summary>
	''' <param name="fileName">A valid file path to add.</param>
	''' <return>Self</return>
	Method addTemplateArchive:ContentDb(fileName:String)
		' [todo] - Check the file exists (take zip:: etc protocols into account)
		Self._templateDirectories.AddLast(fileName)

		Return Self
	End Method


	' ----------------------------------------------------------------------
	' -- Public API -- Querying
	' ----------------------------------------------------------------------

	''' <summary>
	''' Get a string value from a template using a dotted identifier.
	'''
	''' The first part should be the template name and the second the field
	''' name. E.g. "my_object.my_field" will return the value of "my_field" from
	''' the "my_object" template.
	''' </summary>
	''' <param name="path">Dotted path.</param>
	''' <return>The field value.</return>
	Method getTemplateString:String(path:String)
		Local objectName:String = Left(path, path.Find("."))
		Local fieldName:String  = Right(path, path.Length - path.Find(".") - 1)

		' Get the template.
		Local template:EntityTemplate = Self.getObjectTemplate(objectName)
		If template = Null Then Throw "Could not find ObjectTemplate: " + objectName

		' Return the field value.
		Return template.getTemplateString(fieldName)
	End Method

	''' <summary>Count the number of object templates.</summary>
	''' <return>Number of registered object templates.</return>
	Method countObjectTemplates:Int()
		Return Self._objectTemplateList.Count()
	End Method

	''' <summary>Get a ComponentScheme object from the content database.</summary>
	''' <param name="schemaName">The name of the schema to find.</param>
	''' <return>The schema object that was found, or Null if it was not found.</return>
	Method getComponentSchema:ComponentSchema(schemaName:String)
		Return ComponentSchema(Self._componentSchemas.ValueForKey(schemaName.ToLower()))
	End Method

	''' <summary>Get an EntityTemplate object from the content database.</summary>
	''' <param name="templateName">The name of the ObjectTemplate to retrieve.</param>
	''' <return>The GameObjectTemplate object that was found, or null if it was not found.</return>
	Method getObjectTemplate:EntityTemplate(templateName:String)
		Return EntityTemplate(Self._objectTemplates.ValueForKey(templateName.ToLower()))
	End Method

	''' <summary>Gets a list of all of the GameObjectTemplate names within the ContentDb.</summary>
	''' <return>An array of GameObjectTemplate names.</return>
	Method getObjectTemplateList:String[]()
		Local classList:String[]

		For Local template:EntityTemplate = EachIn Self._objectTemplateList
			classList = classList[..classList.length + 1]

			classList[classList.length - 1] = template.getName()
		Next

		Return classList
	End Method

	''' <summary>Gets a list of all the ContentSchema names within the ContentDb.</summary>
	''' <return>A TList of ComponentSchema names.</return>
	Method getComponentSchemaList:TList()
		Return Self._componentSchemaList
	End Method

	''' <summary>
	''' Get a collection of EntityTemplate objects that use `componentName`.
	''' </summary>
	''' <param name="componentName">The component name to search for.</param>
	''' <return>TList of EntityTemplate objects.</return>
	Method getTemplatesWithComponent:TList(componentName:String)

		Local templateList:TList = New TList

		For Local tmp:EntityTemplate = EachIn Self._objectTemplateList
			If tmp.hasComponentTemplate(componentName) Then
				templateList.AddLast(tmp)
			EndIf
		Next

		Return templateList

	End Method


	' ----------------------------------------------------------------------
	' -- Content Building
	' ----------------------------------------------------------------------

	''' <summary>
	''' Build all the object templates in the database.
	'''
	''' Goes through each template and ensures that each component has correct
	''' values set. This must be called before using templates, or all kinds of
	''' weirdness will occur.
	''' </summary>
	Method buildTemplates()
		Self.buildChildTemplates()
	End Method

	''' <summary>Build all the children of a specified template.</summary>
	''' <param name="templateName">Optional name of the template to build children for.</param>
	Method buildChildTemplates(templateName:String = "")

		' Get parent object.
		Local parentTemplate:EntityTemplate	= Self.getObjectTemplate(templateName)

		For Local objTemplate:EntityTemplate = EachIn Self._objectTemplateList

			' If template inherits, add it to our list of templates.
			If objTemplate <> Null And objTemplate.inherits(templateName) Then
				' If this is a root template, all initialisation will be done
				' from schema, otherwise it'll be done from the parent.
				If parentTemplate = Null Then
					Self.buildTemplateFromSchema(objTemplate)
				Else
					Self.buildTemplateFromParent(objTemplate, parentTemplate)
				EndIf

				' Build children.
				Self.buildChildTemplates(objTemplate.getName())
			EndIf

		Next

	End Method

	''' <summary>Builds an object template using values from the component schemas.</summary>
	Method buildTemplateFromSchema(obj:EntityTemplate)
		For Local childComponent:ComponentTemplate = EachIn obj.getComponentTemplates()
			childComponent.copyFromSchema(childComponent.getSchema())
		Next
	End Method

	Method buildTemplateFromParent(obj:EntityTemplate, parent:EntityTemplate)
		' Set the category from the parent if needed.
		If parent._category And obj._category = "" Then
			obj._category = parent._Category
		EndIf

		' Copy across all child components from the parent first.
		For Local childComponent:ComponentTemplate = EachIn parent.getComponentTemplates()

			' If the current template does not already have this component
			' attached, copy the component from the parent.
			If Not obj.hasComponentTemplate(childComponent.getSchemaName()) Then
				Local newComponent:ComponentTemplate = childComponent.Copy()
				newComponent.copyFromSchema(childComponent.getSchema())
				newComponent.copyFromTemplate(childComponent)

				obj.addComponentTemplate(newComponent)
			Else
				' Otherwise, copy fields from the parent that have not been set
				' yet.
				Local t1:ComponentTemplate = obj.getComponentTemplate(childComponent.getSchemaName())
				Local t2:ComponentTemplate = parent.getComponentTemplate(childComponent.getSchemaName())

				t1.copyFromTemplate(t2)
			EndIf

		Next

		' Set any missing defaults.
		For Local component:ComponentTemplate = EachIn obj.getComponentTemplates()
			component.copyFromSchema(component.getSchema())
		Next

	End Method


	' ----------------------------------------------------------------------
	' -- Content Registration
	' ----------------------------------------------------------------------

	Method registerGameObjectTemplate:Int(newTemplate:EntityTemplate)

		' Check template is valud
		If newTemplate = Null Then Return False

		' Add to the database by NAME & add to the list
		Self._objectTemplates.Insert(newTemplate.getIdentifier(), newTemplate)
		Self._objectTemplateList.AddLast(newTemplate)

		Return True

	End Method

	''' <summary>Registers a ComponentSchema with the content database.</summary>
	''' <param name="newSchema">The ComponentSchema object to add.</param>
	Method registerComponentSchema:Int(newSchema:ComponentSchema)

		If newSchema = Null Then Return False

		' Add to the database by NAME
		Self._addComponentSchema(newSchema)

		Return True

	End Method

	Method addComponentsFile(fileName:String)

		' Can't add a file that doesn't exist and isn't a special type of stream
		If fileName.Contains("::") = False And FileType(fileName) <> FILETYPE_FILE Then
			Throw "Attempted to add invalid file '" + fileName + "'"
		EndIf

		Self._componentFiles.AddLast(fileName)

	End Method


	' ----------------------------------------------------------------------
	' -- Load Helpers
	' ----------------------------------------------------------------------

	' [todo] - Refactor this to be taken care of entirely in the ContentDb loader

	Method loadTemplates()

		For Local path:String = EachIn Self._templateDirectories

			' Get the full path
			Local pathName:String = ""

			' Check if this is a stream or other type of file
			If path.Contains("::") Then
				pathName = path
			Else

				If RealPath(path) <> path Then
					pathName = File_Util.PathCombine(CurrentDir(), path)
					If pathName.EndsWith("/") Or pathName.EndsWith("\") Then
						pathName = Left(pathName, pathName.Length - 1)
					End If
				Else
					pathName = path
				End If

			End If

			' [todo] - This doesn't work so great when the template is in a zip file
			Select FileType(pathName)
				Case FILETYPE_DIR  ; Self._loadTemplatesFromDirectory(pathName)
				Case FILETYPE_FILE ; Self._loadTemplateFromFile(pathName)
				Default            ; Self._loadTemplateFromArchive(pathName)
			End Select
		Next

	End Method

	''' <summary>Load templates from a directory.</summary>
	Method _loadTemplatesFromDirectory(path:String)

		' Get all filenames
		Local fileList:String[] = LoadDir(path)
		If fileList = Null Then Return

		' Load each file in the directory
		For Local fileName:String = EachIn fileList

			' Skip directory identifiers
			If fileName = "." Or fileName = ".." Then Continue

			Local fullPath:String = File_Util.PathCombine(path, fileName)

			' Load the template (either from a file or recurse into directory)
			Select FileType(fullPath)
				Case FILETYPE_DIR  ; Self._loadTemplatesFromDirectory(fullPath)
				Case FILETYPE_FILE ; ContentDbLoader.LoadTemplateFromFile(Self, fullPath)
			End Select

		Next

	End Method

	Method _loadTemplateFromFile(path:String)

		Local fileIn:TStream = ReadFile(path)
		Local header:String	= Chr(fileIn.ReadByte()) + Chr(fileIn.ReadByte())
		fileIn.Close()

		Select header
			Case "PK";	Self._loadTemplateFromArchive(path)
			Default;	ContentDbLoader._LoadTemplate(Self, path)
		End Select

	End Method

	' [todo] - Clean this up!!!!! It's hideous
	Method _loadTemplateFromArchive(path:String)

		Local archiveFile:String = path
		Local archiveDir:String  = "/"

		' Extract path & filename
		If path.StartsWith("zip::") Then
			path = Right(path, path.Length - 5)
			archiveFile = ZipHelper._getZipName(path)
			archiveDir  = ZipHelper._getFileName(path)
		End If

		' Get a list of files in this archive
		Local fileIn:ZipReader = New ZipReader
		fileIn.OpenZip(archiveFile)

		' TODO: Extract this
		If fileIn.m_zipFileList.getFileCount() = 0 Then
			DebugLog "No files in archive"
			Return
		EndIf

		For Local zipFileInfo:SZipFileEntry = EachIn fileIn.m_zipFileList.fileList

			Local fileName:String = zipFileInfo.simpleFileName

			' Skip dot files, files not in the archive path and directories
			If fileName = "." Or fileName = ".." Then Continue
			If archiveDir <> "/" And fileName.StartsWith(archiveDir) = False Then Continue
			If fileName.EndsWith("/") Then Continue

			ContentDbLoader.LoadTemplateFromArchive(Self, fileIn, fileName)

		Next

		fileIn.CloseZip()

	End Method


	' ----------------------------------------------------------------------
	' -- Component schema setup
	' ----------------------------------------------------------------------

	''' <summary>
	''' Load component schemas from registered schema files. Files must
	''' be registered using the addComponentsFile method.
	''' </summary>
	''' <seealso>addComponentsFile</seealso>
	Method loadComponentsFiles()

		' [todo] - Have the ContentDbLoader load each file and merge it?
		For Local fileName:String = EachIn Self._componentFiles

			PangolinProfiler.startProfile("loadComponentSchema")
			Local components:TList = ContentDbLoader.loadComponentSchema(filename)
			if components = null then throw "Could not find ComponentSerializer from '" + fileName + "'"
			PangolinProfiler.stopProfile("loadComponentSchema")

			For Local c:ComponentSchema = EachIn components
				PangolinProfiler.startProfile("_addComponentSchema")
				Self._addComponentSchema(c)
				PangolinProfiler.stopProfile("_addComponentSchema")
			Next
		Next

	End Method

	''' <summary>
	''' Build component schema using reflection.
	'''
	''' This method isn't as flexible as a user-defined schema, but is useful during
	''' development when things are changing.
	''' </summary>
	''' <description>
	''' All EntityComponent types (including sub-types) will be scanned during this
	''' process. Any public field (i.e. field that does not start with a `_` character)
	''' will be added to the schema.
	''' </description>
	Method autobuildComponentSchemas()
		Self._extractComponentSchemaForType(TTypeId.ForName("EntityComponent"))
	End Method

	Method _extractComponentSchemaForType(typeInfo:TTypeId)
		' Extract info from all child types.
		For Local childType:TTypeId = EachIn typeInfo.DerivedTypes()
			Self._extractComponentSchemaForType(childType)
		Next

		' Create the component schema.
		Local schema:ComponentSchema = ComponentSchema.Create(typeInfo.MetaData("name"), typeInfo.MetaData("doc"))

		' Get each field.
		For Local fieldInfo:TField = EachIn typeInfo.EnumFields()
			' Ignore private fields.
			If fieldInfo.Name().StartsWith("_") Then Continue

			' If field is internal, add it immediately and ignore any meta.
			If fieldInfo.MetaData("internal") Then
				schema._internals.AddLast(fieldInfo.Name())
				Continue
			EndIf

			' Create field schema and setup info.
			Local fieldSchema:ComponentField = New ComponentField
			fieldSchema.setName(fieldInfo.Name())
			fieldSchema.setDataType(Self._getDataTypeNameForTTypeId(fieldInfo.TypeId()))
			fieldSchema.setDescription(fieldInfo.MetaData("doc"))
			fieldSchema.setProtectionLevel(ComponentField.PROTECTIONLEVEL_PUBLIC)

			' Add to the component schema.
			schema.addField(fieldSchema)
		Next

		' Register the schema.
		Self._addComponentSchema(schema)

	End Method

	Method _getDataTypeNameForTTypeId:String(typeInfo:TTypeId)
		Select typeInfo.Name()
			Case "Byte"
				Return "bool"

			Case "String"
				Return "string";

			Case "Int", "Short", "Long"
				Return "int"

			Case "Float"
				Return "float"
		End Select
	End Method


	' ----------------------------------------------------------------------
	' -- Internal helpers
	' ----------------------------------------------------------------------

	Method _addComponentSchema(c:ComponentSchema)
		Self._componentSchemas.Insert(c.GetName(), c)
		Self._componentSchemaList.AddLast(c)
	End Method

	Method _countComponents:Int()
		Return Self._componentSchemaList.count()
	End Method

	Method _dumpAll:String()

		Local output:String

		For Local t:EntityTemplate = EachIn Self._objectTemplates.Values()
			output :+ t._dump() + "~n~n"
		Next

		Return output

	End Method


	' ----------------------------------------------------------------------
	' -- Creation / Destruction
	' ----------------------------------------------------------------------

	''' <summary>Creates and initialises a new ContentDb object and returns it.</summary>
	''' <return>The newly created ContentDb object.</return>
	Function Create:ContentDb()
		Return New ContentDb
	End Function

	''' <summary>Initialises the internals of a ContentDb object.</summary>
	Method New()

		Self._objectTemplates		= New TMap
		Self._componentSchemas		= New TMap

		Self._objectTemplateList	= New TList
		Self._componentSchemaList	= New TList

		Self._componentFiles		= New TList
		Self._templateDirectories	= New TList

	End Method

End Type
