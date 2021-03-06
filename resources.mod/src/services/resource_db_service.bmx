' ------------------------------------------------------------------------------
' -- src/services/resource_db_service.bmx
' --
' -- Service that wraps a resource manager.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.core

Import "../resource_manager.bmx"

Type ResourceDbService Extends GameService

	Field _resources:ResourceManager


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
		Self._resources.enableStrictChecking()
	End Method

	''' <summary>Disable strict checking for the resource manager.</summary>
	Method disableStrictChecking()
		Self._resources.disableStrictChecking()
	End Method


	' ------------------------------------------------------------
	' -- Retrieving Resources
	' ------------------------------------------------------------

	''' <summary>Get a list of all resource names.</summary>
	''' <return>A list of resource names that the resource manager contains.</return>
	Method getResourceList:TList()
		Return Self._resources.getResourceList()
	End Method

	''' <summary>Retrieve a resource by name.</summary>
	''' <param name="resourceName">Full name of the resource to retrieve.</param>
	''' <param name="doNotLoad">If true, the resource will not be loaded.</param>
	''' <return>The resource, or Null if it does not exist.</return>
	Method get:BaseResource(resourceName:String, doNotLoad:Byte = False)
		Return Self._resources.getResource(resourceName, doNotLoad)
	End Method

	''' <summary>Retrieve a resource's object by name.</summary>
	''' <param name="resourceName">Full name of the resource to retrieve.</param>
	''' <param name="doNotLoad">If true, the resource will not be loaded.</param>
	''' <return>The resource, or Null if it does not exist.</return>
	Method getObject:Object(resourceName:String, doNotLoad:Byte = False)
		Local resource:BaseResource = Self.get(resourceName, doNotLoad)
		if resource Then Return resource.get()
	End Method


	' ------------------------------------------------------------
	' -- Loading resources
	' ------------------------------------------------------------

	''' <summary>Load resource definitions from multiple files.</summary>
	''' <param name="files">List of resource definition files to load.</param>
	''' <param name="isLazy">If true, resources will not be loaded until accessed.</param>
	Method loadAssets(files:TList, isLazy:Byte = True)
		For Local file:String = EachIn files
			Self.loadResourceFile(file, isLazy)
		Next
	End Method

	''' <summary>Load resource definitions from a file.</summary>
	''' <param name="fileName">The resource definition file to load.</param>
	''' <param name="isLazy">If true, resources will not be loaded until accessed.</param>
	Method loadResourceFile(fileName:String, isLazy:Byte = True)
		Self._resources.loadResources(fileName, isLazy)
	End Method

	''' <summary>Reload all resources.</summary>
	Method reload()
		Self._resources.reloadAll()
	End Method


	' ------------------------------------------------------------
	' -- Clearing assets
	' ------------------------------------------------------------

	Method unloadAssets(assets:TList)
		' TODO: Add this - it should remove resources from the manager AND free them
	End Method


	' ------------------------------------------------------------
	' -- Callbacks
	' ------------------------------------------------------------

	''' <summary>
	''' Event hook that is called when a resource definition file is loaded. Called 
	''' before loading of individual resources.
	'''
	''' Callbacks will receive a GameEvent, where the `extra` field contains the
	''' name of the resource file being loaded.
	''' </summary>
	''' <param name="callback">Event handler.</param>
	''' <return>ResourceDbService instance.</return>
	Method whenLoadStarted:ResourceDbService(callback:EventHandler)
		Self._resources.whenLoadStarted(callback)

		Return Self
	End Method

	''' <summary>
	''' Event hook that is called when a resource definition file has finished being
	''' loaded.
	'''
	''' Callbacks will receive a GameEvent, where the `extra` field contains the
	''' name of the resource file that was loaded.
	''' </summary>
	''' <param name="callback">Event handler.</param>
	''' <return>ResourceManager instance.</return>
	Method whenLoadFinished:ResourceDbService(callback:EventHandler)
		Self._resources.whenLoadFinished(callback)

		Return Self
	End Method

	''' <summary>
	''' Event hook that is called when single resource in a resource definition has
	''' been loaded.
	'''
	''' Callbacks will receive a GameEvent, where the `extra` field contains the
	''' `BaseResource` object that was loaded.
	''' </summary>
	''' <param name="callback">Event handler.</param>
	''' <return>ResourceDbService instance.</return>
	Method whenResourceLoaded:ResourceDbService(callback:EventHandler)
		Self._resources.whenResourceLoaded(callback)

		Return Self
	End Method


	' ------------------------------------------------------------
	' -- Creation / Setup
	' ------------------------------------------------------------

	Method New()
		Self._resources = New ResourceManager
	End Method

End Type
