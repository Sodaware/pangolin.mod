' ------------------------------------------------------------------------------
' -- content_db.bmx
' -- 
' -- The ContentDb class is a database of object templates that can be used 
' -- when spawning game entities. Full-integrated with pangolin.entities.
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

Import gman.zipengine

Import sodaware.File_Util
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


''' <summary>Manages all object templates and schemas.</summary>
Type ContentDb
	
	' -- Hashes to store templates and schemas
	Field _objectTemplates:Tmap             '''< Map of TemplateName => ObjectTemplate
	Field _componentSchemas:Tmap            '''< Map of SchemaName => ComponentSchema
	
	' -- Lists
	Field _objectTemplateList:TList         '''< List of object templates
	Field _componentSchemaList:TList        '''< List of component schemas
	
	' -- Internal file lists
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
		' [todo] - Check the directory exists (take zip:: etc protocols into account)
		Self._templateDirectories.AddLast(pathName)
		Return Self
	End Method
	
	''' <summary>
	''' Add an archive file files to scan for templates.
	''' </summary>
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
	''' Get a string value from a template using a dotted identifier. The first
	''' part should be the template name and the second the field name.
	''' </summary>
	''' <param name="path">Dotted path.</param>
	Method getTemplateString:String(path:String)
		
		' Get the template
		Local template:EntityTemplate = Self.getObjectTemplate(Left(path, path.Find(".")))
		If template = Null Then Throw "Could not find ObjectTemplate: " + Left(path, path.Find("."))
		
		' Return the field value
		Return template.getTemplateString(Right(path, path.Length - path.Find(".") - 1))
	
	End Method
	
	' [todo] - Optimize this
	Method countObjectTemplates:Int()
		Return Self._objectTemplateList.Count()
	End Method
	
	''' <summary>Gets a Component Scheme object from the content database.</summary>
	''' <param name="schemaName">The name of the schema to find.</param>
	''' <returns>The schema object that was found, or null if it was not found.</returns>
	Method getComponentSchema:ComponentSchema(schemaName:String)
		Return ComponentSchema(Self._componentSchemas.ValueForKey(schemaName.ToLower()))
	End Method
	
	''' <summary>Gets a Game Object Template object from the content database.</summary>
	''' <param name="templateName">The name of the ObjectTemplate to retrieve.</param>
	''' <returns>The GameObjectTemplate object that was found, or null if it was not found.</returns>
	Method getObjectTemplate:EntityTemplate(templateName:String)
		if templateName = "" then return null
		Return EntityTemplate(Self._objectTemplates.ValueForKey(templateName.ToLower()))
	End Method
	
	''' <summary>Gets a list of all of the GameObjectTemplate names within the ContentDb.</summary>
	''' <returns>A list of GameObjectTemplate names.</returns>
	Method getObjectTemplateList:TList()
	
		Local classList:TList	= New TList
		
		For Local template:EntityTemplate = EachIn Self._objectTemplateList
			classList.AddLast(template.GetName())
		Next
		
		Return classList
		
	End Method

	''' <summary>Gets a list of all the ContentSchema names within the ContentDb.</summary>
	''' <returns>A TList of ComponentSchema names.</returns>
	Method getComponentSchemaList:TList()
		Return Self._componentSchemaList
	End Method
	
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
	
	''' <summary>Build all the object templates in the database. Sets up inheritance etc.</summary>
	Method buildTemplates()
		Self.buildChildTemplates()
	End Method

	''' <summary>Build all the children of a specified template.</summary>
	''' <param name="templateName">Optional name of the template to build children for.</param>
	Method buildChildTemplates(templateName:String = "")
		
		' Get parent object.
		Local parentTemplate:EntityTemplate	= Self.getObjectTemplate(templateName)

		For Local objTemplate:EntityTemplate = EachIn Self._objectTemplateList
		
			' If template inherits, add it to our list of templates
			If objTemplate <> Null And objTemplate.inherits(templateName) Then
				
				' If this is a root template, all initialisation will be done from schema, otherwise
				'	it'll be done from the parent
				If parentTemplate = Null Then
					Self.buildTemplateFromSchema(objTemplate)
				Else						
					Self.buildTemplateFromParent(objTemplate, parentTemplate)
				EndIf
				
				' Build children
				Self.buildChildTemplates(objTemplate.getName())
				
			EndIf
			
		Next
		
	End Method


	''' <summary>Build all the children of a specified template.</summary>
	''' <param name="templateName">Optional name of the template to build children for.</param>
	Method LEGACY_buildChildTemplates(templateName:String = "")
		
		' Get parent object.
		Local parentTemplate:EntityTemplate	= Self.getObjectTemplate(templateName)

		' Create a new queue. Do we even need to do this? NO
		Local templateQueue:TList = new TList
		For Local t:EntityTemplate = EachIn Self._objectTemplateList
			templateQueue.addLast(t)
		Next
		
		For Local objTemplate:EntityTemplate = EachIn templateQueue
		
			' If template inherits, add it to our list of templates
			If objTemplate <> Null And objTemplate.inherits(templateName) Then
				
				' If this is a root template, all initialisation will be done from schema, otherwise
				'	it'll be done from the parent
				If parentTemplate = Null Then
					Self.buildTemplateFromSchema(objTemplate)
				Else						
					Self.buildTemplateFromParent(objTemplate, parentTemplate)
				EndIf
				
				' Build children
				Self.buildChildTemplates(objTemplate.getName())
				
				'Remove from queue
				templateQueue.Remove(objTemplate)
					
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
		
		'	2) If parent is set, iterate through parent components
		'		If child doesn't have this component, create it & add it
		' Set the category
		If parent._category And obj._category = "" Then
			obj._Category = parent._Category
		endif
		
		For Local childComponent:ComponentTemplate = EachIn parent.getComponentTemplates()
			
			If obj.hasComponentTemplate(childComponent.getSchemaName()) = False Then
				
				Local newComponent:ComponentTemplate = childComponent.Copy()
				newComponent.copyFromTemplate(childComponent)
				obj.addComponentTemplate(newComponent)
				
			Else
				
				Local t1:ComponentTemplate	= obj.getComponentTemplate(childComponent.getSchemaName())
				Local t2:ComponentTemplate	= parent.getComponentTemplate(childComponent.getSchemaName())
				
				t1.copyFromTemplate(t2)
				
			EndIf
			
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

	Method registerComponentTemplate(newTemplate:ComponentTemplate)
		RuntimeError("Whoops!")
	'	If this = Null Then Return False
'		If newTemplate = Null Then Return False
		
'		Return False
		
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

			debuglog "Loading template: " + pathName


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
			
debuglog " :: " + fileName

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
	''' Build component schemas using reflection. This method is a slower 
	''' than loading them from a file so must be called manually.
	''' </summary>
	Method autobuildComponentSchemas()
		
		' Get the base component type
		' Get all child types
		
		' Get each field
		' Parse meta data (if present) for description/default
		' Add to the component schema
		' Register the schema
		
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
	''' <returns>The newly created ContentDb object.</returns>
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
