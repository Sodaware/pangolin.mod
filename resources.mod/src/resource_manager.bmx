' ------------------------------------------------------------------------------
' -- src/resource_manager.bmx
' --
' -- Main resource manager class. A resource manager can load resource
' -- definitions either from an external definition or via code. Normally a game
' -- will have only one resource manager, wrapped inside a service (see
' -- Pangolin.Services for an existing ResourceManagerService).
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2020 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.filesystem
Import brl.map
Import brl.reflection
Import brl.stream

Import pangolin.events

Import "base_resource.bmx"
Import "resource_definition.bmx"
Import "resource_file_serializer.bmx"
Import "resource_events.bmx"
Import "resource_exceptions.bmx"

''' <summary>
''' Main resource manager type.
'''
''' A resource manager can load resource definitions either from an external
''' definition or via code. Normally a game will have only one resource manager
''' wrapped inside a service.
''' </summary>
Type ResourceManager

	' -- Options
	Field _isStrictCheckingEnabled:Byte = False

	Field _resources:TMap       '''< Map of all resources names -> resources.
	Field _totalFiles:Int       '''< Number of files loaded.

	' -- Caches
	Field _resourceTypes:TMap	'''< Map of string -> TTypeId.

	' -- Callbacks
	Field _hooks:Hooks


	' ------------------------------------------------------------
	' -- Callbacks
	' ------------------------------------------------------------

	''' <summary>
	''' Event hook that is called when a resource manifest file is loaded.
	'''
	''' This is called *before* individual resources are loaded.
	'''
	''' Handlers receive a `ResourceManifestEvent`, which contains the name of
	''' the resource file being loaded, along with the current serializer.
	''' </summary>
	''' <param name="callback">Event handler.</param>
	''' <return>ResourceManager instance.</return>
	Method whenLoadStarted:ResourceManager(callback:EventHandler)
		Self._hooks.add("load_started", callback)

		Return Self
	End Method

	''' <summary>
	''' Event hook that is called when a resource manifest file has finished loading.
	'''
	''' Handlers receive a `ResourceManifestEvent`, which contains the name of
	''' the resource file being loaded, along with the current serializer.
	''' </summary>
	''' <param name="callback">Event handler.</param>
	''' <return>ResourceManager instance.</return>
	Method whenLoadFinished:ResourceManager(callback:EventHandler)
		Self._hooks.add("load_finished", callback)

		Return Self
	End Method

	''' <summary>
	''' Event hook that is called when single resource in a manifest has been loaded.
	'''
	''' Handlers receive a `ResourceLoadedEvent`, which contains the
	''' `BaseResource` object that was loaded.
	''' </summary>
	''' <param name="callback">Event handler.</param>
	''' <return>ResourceManager instance.</return>
	Method whenResourceLoaded:ResourceManager(callback:EventHandler)
		Self._hooks.add("resource_loaded", callback)

		Return Self
	End Method


	' ------------------------------------------------------------
	' -- Setting Options
	' ------------------------------------------------------------

	''' <summary>
	''' Enable strict checking for the resource manager.
	'''
	''' When enabled, the manager will throw exceptions when resources are not
	''' found.
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
				Throw MissingResourceException.Create(resourceName)
			End If
			Return Null
		EndIf

		' Load the resource if not already loaded
		If doNotLoad = False And resource._isLoaded = False Then resource.reload()

		Return resource

	End Method

	''' <summary>
	''' Free a resource by name.
	'''
	''' This unloads any data it has loaded, but does not remove it from the
	''' resource manager.
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
	''' <param name="name">The name of the resource to remove.</param>
	Method removeResource(name:String)
		Self._resources.Remove(name)
	End Method


	' ------------------------------------------------------------
	' -- Resource Loading
	' ------------------------------------------------------------

	''' <summary>Loads all resources from a resource definition file.</summary>
	''' <param name="filename">The resource definition file to load.</param>
	''' <param name="isLazy">If true, resources will not be loaded until requested.</param>
	Method loadResources(filename:String, isLazy:Byte = True)

		Local loader:ResourceFileSerializer = Self._getSerializer(filename)
		If loader = Null Then Throw MissingResourceSerializerException.Create(filename)

		' Notify listeners that loading has started.
		Self._hooks.sendEvent(ResourceManifestEvent.Build(filename, loader, "load_started"))

		' Setup loader.
		loader.init(filename)

		' Load each resource definition.
		For Local definition:ResourceDefinition = EachIn loader.getResources()

			' Create a resource from each definition.
			Local resource:BaseResource = Self.addResource(definition)
			Self._resources.Insert(definition.getFullName(), resource)

			' Load resource completely if laziness disabled AND they're not skipping autoload.
			If isLazy = False And definition.skipAutoload() = False Then
				resource.reload()

				' Notify listeners.
				Self._hooks.sendEvent(ResourceLoadedEvent.Build(resource))
			End If

		Next

		' Notify listeners that loading has finished.
		Self._hooks.sendEvent(ResourceManifestEvent.Build(filename, loader, "load_finished"))

	End Method

	''' <summary>Reload all resources.</summary>
	Method reloadAll()

		' TODO: ResourceManager.reloadAll would be better to use an objectbag, rather than iterating through mapped resources
		For Local resource:BaseResource = EachIn Self._resources.Values()
			resource.reload()
			Self._hooks.sendEvent(ResourceLoadedEvent.Build(resource))
		Next

	End Method


	' ------------------------------------------------------------
	' -- Load a single resource
	' ------------------------------------------------------------

	''' <summary>
	''' Loads a Resource from a ResourceDefinition.
	'''
	''' Will throw an exception if if no valid Resource exists for this type.
	''' </summary>
	''' <param name="definition">The resource definition to load.</param>
	''' <return>Loaded resource</return>
	Method addResource:BaseResource(definition:ResourceDefinition)

		' Get the BlitzMax type for this resource name.
		Local resourceType:TTypeId = Self.getResourceTypeByName(definition.getType())

		' If resource type is invalid, throw an exception.
		If Null = resourceType Then
			Throw InvalidResourceTypeException.Create(definition.getType())
		EndIf

		' Load the resource and return it.
		Local resource:BaseResource = BaseResource(resourceType.NewObject())
		resource.init(definition)

		Return resource

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
	' -- Resource type helpers
	' ------------------------------------------------------------

	Method isValidResourceType:Byte(name:String)
		Return Self._resourceTypes.ValueForKey(name) <> Null
	End Method

	Method getResourceTypeByName:TTypeId(name:String)
		Return TTypeId(Self._resourceTypes.ValueForKey(name))
	End Method


	' ------------------------------------------------------------
	' -- Cache Helpers
	' ------------------------------------------------------------

	Method _initializeTypeCaches()

		' Get all available resource types
		Local baseType:TTypeId = TTypeId.ForName("BaseResource")
		For Local resourceType:TTypeId = EachIn baseType.DerivedTypes()

			' Type name meta may be comma separated, so split the name and add each item.
			Local typeNames:String[] = resourceType.MetaData("resource_type").Split(",")
			For Local typeName:String = EachIn typeNames
				Self._resourceTypes.Insert(typeName.ToLower().Trim(), resourceType)
			Next

		Next

	End Method


	' ------------------------------------------------------------
	' -- Construction / Destruction
	' ------------------------------------------------------------

	Method New()
		Self._resources		= New TMap
		Self._resourceTypes = New TMap

		Self._initializeTypeCaches()

		' Setup hooks.
		Self._hooks = New Hooks
		Self._hooks.registerHook("load_started")
		Self._hooks.registerHook("load_finished")
		Self._hooks.registerHook("resource_loaded")
	End Method

End Type
