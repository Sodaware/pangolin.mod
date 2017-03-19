' ------------------------------------------------------------------------------
' -- src/resource_manager.bmx
' -- 
' -- Main resource manager class. A resource manager can load resource
' -- definitions either from an external definition or via code. Normally a game
' -- will have only one resource manager, wrapped inside a service (see 
' -- Pangolin.Services for an existing ResourceManagerService).
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.map
Import brl.max2d
Import brl.audio

Import brl.reflection

Import brl.stream

Import "base_resource.bmx"
Import "resource_definition.bmx"
Import "resource_file_serializer.bmx"

''' <summary>
''' Main resource manager type. A resource manager can load resource 
''' definitions either from an external definition or via code. Normally a 
''' game will have only one resource manager wrapped inside a service.
''' </summary>
Type ResourceManager

	' -- Options
	Field _isStrictCheckingEnabled:Byte = False

	Field _resources:TMap     	'''< Map of all resources
	Field _loadCallbacks:TList 	'''< List of functions to be called when file loaded
	Field _totalFiles:Int = 0	'''< Number of files loaded
	
	Field _callbackCaller:Object
	Field _startCallback:Object(called:Object, file:String)
	
	Method setStartCallback(caller:Object, callback:Object(caller:Object, file:String))
		Self._callbackCaller	= caller
		Self._startCallback 	= callback
	End Method
	
	' TODO: Callback list?
	Method addCallback(callback(resource:BaseResource))
		'Self._loadCallbacks.AddLast(callback)
	End Method
	
	Method removeCallback(callback(resource:BaseResource))
		'Self._loadCallbacks.Remove(callback)
	End Method
	
	Method clearCallbacks()
		'Self._loadCallbacks.Clear()
	End Method
	
	
	' ------------------------------------------------------------
	' -- Setting Options
	' ------------------------------------------------------------

	''' <summary>
	''' Enable strict checking for the resource manager. When enabled, the
	''' manager will throw exceptions when resources are not found.
	''' </summary>
	Method enableStrictChecking()
		Self._isStrictCheckingEnabled = True
	End Method
	
	''' <summary>Disable strict checking for the resource manager.</summary>
	Method disableStrictChecking()
		Self._isStrictCheckingEnabled = False
	End Method
	
	
	' ------------------------------------------------------------
	' -- Getting Resources
	' ------------------------------------------------------------
	
	''' <summary>Get a resource.</summary>
	''' <param name="resourceName">name of the resource to load</param>
	''' <param name="doNotLoad">If true, will not load file (if not already loaded)</param>
	''' <return>The loaded result, or Null if the resource was not found.</return>
	Method getResource:BaseResource(resourceName:String, doNotLoad:Byte = False)
		
		Local resource:BaseResource = Self._getResource(resourceName)
		
		If resource Then
			resource._increaseCount()
		Else
			DebugLog "ResourceManager->getResource() - Could not find: " + resourceName
			If Self._isStrictCheckingEnabled Then
				' TODO: Replace with a proper exception.
				Throw "ResourceManager->getResource() - Could not find: " + resourceName
			End If
			Return Null
		EndIf
		
		' Load the resource if not already loaded
		If doNotLoad = False And resource._isLoaded = False Then resource.reload()
		
		Return resource
		
	End Method
	
	''' <summary>
	''' Free a resource by name. This unloads any data it has loaded, but does 
	''' not remove it from the resource manager.
	''' </summary>
	Method freeResource(resourceName:String)
		Local resource:BaseResource = Self._getResource(resourceName)
		If resource Then resource.free()
	End Method
	
	''' <summary>Get a list of all resource names that have been added to the manager.</summary>
	''' <return>A list of resource names that the resource manager contains.</return>
	Method getResourceList:TList()
		Local resources:TList = New TList
		
		For Local res:BaseResource = EachIn Self._resources.Values()
			resources.AddLast(res._definition.getFullName())
		Next
		
		Return resources
	End Method
	
	Method _getResource:BaseResource(resourceName:String)
		Return BaseResource(Self._resources.ValueForKey(resourceName))
	End Method
	
	''' <summary>Remove a resource from the manager by name.</summary>
	Method removeResource(name:String)
		Self._resources.Remove(name)
	End Method
	
	' ------------------------------------------------------------
	' -- Resource Loading
	' ------------------------------------------------------------
	
	''' <summary>Loads all resources from a resource file.</summary>
	Method loadResources(filename:String, isLazy:Byte = True)
		
		Local loader:ResourceFileSerializer = Self._getSerializer(fileName)
		If loader = Null Then Throw "No resource serializer found for type: " + ExtractExt(filename)
		
		' Signal!
		If Self._startCallback <> Null Then
			Self._startCallback(Self._callbackCaller, filename)	
		End If
		
		' Setup loader
		loader.init(filename)
		
		' Load each resource definition
		For Local definition:ResourceDefinition = EachIn loader.getResources()
			
			If Self._startCallback <> Null Then
			'	Self._startCallback(Self._callbackCaller, definition.getFileName())
			End If

			' Create a resource from each definition
			Local resource:BaseResource = Self.addResource(definition)
			Self._resources.Insert(definition.getFullName(), resource)
			
			' Load resource completely if laziness disabled
			If isLazy = False Then
				resource.reload()
				Self._onFileLoaded(resource)
			End If
			
        Next
		
	End Method
   
	''' <summary>Reloads all resources.</summary>
	Method reloadAll()
		
		' TODO: ResourceManager.reloadAll would be better to use an objectbag, rather than iterating through mapped resources
		For Local resource:BaseResource = EachIn Self._resources.Values()
			resource.reload()
			Self._onFileLoaded(resource)
		Next       
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Load Callbacks
	' ------------------------------------------------------------
	
	Method _onFileLoaded(resource:BaseResource)
		If Self._loadCallbacks.Count() = 0 Then Return
'		For Local callback(res:BaseResource) = EachIn Self._loadCallbacks
'			callback(resource)
'		Next
	End Method
	
	' ------------------------------------------------------------
	' -- Load a single resource
	' ------------------------------------------------------------
	
	''' <summary>
	''' Loads a Resource from a ResourceDefinition. Will throw an exception if
	''' if no valid Resource exists for this type.
	''' </summary>
	''' <param name="definition">The resource definition to load.</param>
	''' <return>Loaded resource</return>
	Method addResource:BaseResource(definition:ResourceDefinition)
		
		' Get all available resources
		Local baseType:TTypeId = TTypeId.ForName("BaseResource")
		For Local resourceType:TTypeId = EachIn baseType.DerivedTypes()
		
			' If resource type maps to definition.type then create the resource
			If resourceType.MetaData("resource_type").Contains(definition.getType()) Then
				
				Local resource:BaseResource = BaseResource(resourceType.NewObject())
				resource.init(definition)
				Return resource
				
			End If
		Next
		
		Throw "Resource type ~q" + definition.getType() + "~q does not exist"
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Serialization Helpers
	' ------------------------------------------------------------
	
	''' <summary>Get the serializer for a filename.</summary>
	''' <param name="fileName">The file to fetch a serializer for.</param>
	''' <return>Serializer for this file type, or null if none available.</return>
	Method _getSerializer:ResourceFileSerializer(fileName:String)
		
		' Get file extension
		Local extension:String = ExtractExt(fileName.ToLower())
		
		' Check every available serializer
		Local baseType:TTypeId = TTypeId.ForName("ResourceFileSerializer")
		For Local serializerType:TTypeId = EachIn baseType.DerivedTypes()
			
			' Check if this type supports the extension
			If serializerType.MetaData("extensions").Contains(extension) Then
				Return ResourceFileSerializer(serializerType.NewObject())
			End If
			
		Next
		
		' None found
		Return Null
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Construction / Destruction
	' ------------------------------------------------------------
	
	Method New()
		Self._resources 	= New TMap
		Self._loadCallbacks = New TList
	End Method
			
End Type
