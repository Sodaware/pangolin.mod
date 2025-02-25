' ------------------------------------------------------------------------------
' -- src/kernel/game_kernel.bmx
' -
' -- Main kernel for Pangolin games. Takes care of executing services in the
' -- correct order. Basically just a fancier game loop.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.map
Import brl.reflection

Import "../services/game_service_locator.bmx"
Import "../services/game_service_collection.bmx"
Import "../services/game_service.bmx"

Include "../services/kernel_information_service.bmx"

''' <summary>
''' Main kernel for pangolin games.
'''
''' All services are registered by TTypeId. This can either be the TTypeId for
''' the service OR its parent. This can be used to ensure there is only a single
''' service of a particular type, but allow the implementation class to change.
''' </summary>
Type GameKernel

	Field _serviceLookup:GameServiceLocator         '''< Maps service types to their instances.

	Field _serviceList:GameServiceCollection        '''< All services registered to the Kernel.
	Field _updateServices:GameServiceCollection     '''< All services that need to be called during an update.
	Field _renderServices:GameServiceCollection     '''< All services that need to be called during a render.

	Field _nextServiceId:Int                        '''< The next available service id.


	' ------------------------------------------------------------
	' -- Querying Services
	' ------------------------------------------------------------

	''' <summary>Check if the kernel has a particular service type registered.</summary>
	''' <param name="serviceType">The TTypeId of the service to check for.</param>
	''' <return>True if service is registered, false if not.</return>
	Method hasServiceType:Byte(serviceType:TTypeId)
		Return (Self._serviceLookup.ValueForKey(serviceType) <> Null)
	End Method

	''' <summary>Gets all services registered to the kernel.</summary>
	Method getServices:GameServiceCollection()
		Return Self._serviceList
	End Method

	''' <summary>Retrieve a service from the kernel using its TTypeId.</summary>
	''' <param name="serviceType">The TTypeId to lookup. Must be non-null</param>
	''' <return>The found service instance.</return>
	Method getService:GameService(serviceType:TTypeId)

		' Check that a proper service type was passed in
		Assert serviceType, "Cannot getService for invalid type"

		' Return the service
		Return Self._serviceLookup.get(serviceType)

	End Method

	''' <summary>
	''' Get a service instance by its type name.
	'''
	''' Will throw an exception if the type name does not exist.
	''' </summary>
	''' <param name="serviceName">The Type name of the service to find.</param>
	''' <return>The found service instance.</return>
	Method getServiceByName:GameService(serviceName:String)

		' Find the type data for the name
		Local serviceType:TTypeId = TTypeId.ForName(serviceName)

		' Check service type actually exists
		If serviceType = Null Then
			Throw "Could not get service for type '" + serviceName + "' - type not defined"
		EndIf

		' Get the service
		Return Self.getService(serviceType)

	End Method


	' ------------------------------------------------------------
	' -- Controlling Services
	' ------------------------------------------------------------

	''' <summary>Start a service.</summary>
	''' <param name="serviceType">TTypeId of the service to start.</param>
	''' <return>True if the service started, false if not.</return>
	Method startService:Byte(serviceType:TTypeId)

		Local service:GameService = Self.getService(serviceType)
		If service = Null Then Return False

		' Check if service is already running
		If service.isRunning() Then Return False

		' Add to list of running services
		Self._addIfImplements(service, "update", Self._updateServices)
		Self._addIfImplements(service, "render", Self._renderServices)

		' Call its start method
		service.start()

		Return True

	End Method

	''' <summary>
	''' Stops a service. Stopped services will no longer update or
	''' render until started again.
	''' </summary>
	Method stopService:Byte(serviceType:TTypeId)

		Local service:GameService = Self.getService(serviceType)
		If service = Null Then Return False

		' Check if service is already stopped
		If service.isRunning() = False Then Return False

		' Remove from list of running services
		Self._updateServices.removeObject(service)
		Self._renderServices.removeObject(service)

		' Call its stop method
		service.stop()

		Return True

	End Method


	' ------------------------------------------------------------
	' -- Adding / Removing services
	' ------------------------------------------------------------

	''' <summary>
	''' Add a service to the kernel.
	'''
	''' ServiceType is usually just the `TTypeID` for the serviceProvider being
	''' passed in (use null to set it automatically). However, it can also be
	''' used to replace a service.
	'''
	''' For example, a `TTypeId` of `AbstractRenderService` could then be used
	''' when setting any of its children, whilst keeping just one service.
	''' </summary>
	''' <param name="serviceType">The type (TTypeId) of the service to add. Use null to auto-detect.</param>
	''' <param name="serviceProvider">GameService instance.</param>
	''' <return>True if the service was added, false if not.</return>
	Method addService:Byte(serviceType:TTypeId, serviceProvider:GameService)

		' Check inputs.
		If serviceProvider = Null Then Return False
		If serviceType = Null Then serviceType = TTypeId.ForObject(serviceProvider)

		' Add to service locator.
		Self._serviceLookup.set(serviceType, serviceProvider)
		Self._serviceList.add(serviceProvider)

		' Check for update and render method.
		Self._addIfImplements(serviceProvider, "update", Self._updateServices)
		Self._addIfImplements(serviceProvider, "render", self._renderServices)

		' Set the unique ID.
		serviceProvider._id = Self._nextServiceId
		Self._nextServiceId:+ 1

		' Inject dependencies.
		If serviceProvider.hasDependencies() Then
			For Local dependency:TTypeId = EachIn serviceProvider.getDependencies()
				serviceProvider.inject(dependency, Self.getService(dependency))
			Next
		End If

		' Initialize the service
		serviceProvider.onInit()

		Return True

	End Method

	''' <summary>Remove a service from the kernel.</summary>
	''' <return>True if service was removed, false if not.</return>
	Method removeService:Byte(serviceType:TTypeId)

		' Check inputs
		If serviceType = Null Then Return False

		' Get the service to be removed
		Local serviceProvider:GameService = Self._serviceLookup.get(serviceType)
		If serviceProvider = Null Then Return False

		' Remove from lookup
		Self._serviceLookup.unset(serviceType)
		Self._serviceList.removeObject(serviceProvider)

		' Remove from update collection (if set)
		If GameKernel.serviceImplements(serviceProvider, "update") Then
			Self._updateServices.removeObject(serviceProvider)
		End If

		' Remove from render collection (if set)
		If GameKernel.serviceImplements(serviceProvider, "render") Then
			Self._renderServices.removeObject(serviceProvider)
		End If

		Return True

	End Method

	''' <summary>Sort all service lists by priority.</summary>
	Method updatePriorities()
		self._serviceList.sort(GameServiceCollection.SORT_DESC)
		self._updateServices.sort(GameServiceCollection.SORT_DESC)
		self._renderServices.sort(GameServiceCollection.SORT_DESC)
	End Method


	' ------------------------------------------------------------
	' -- Starting / Stopping
	' ------------------------------------------------------------

	''' <summary>Start the kernel and all services.</summary>
	Method start()
		For Local serviceProvider:GameService = EachIn Self._serviceList
			serviceProvider.start()
		Next
	End Method

	''' <summary>Stop the kernel and all services.</summary>
	Method stop()
		For Local serviceProvider:GameService = EachIn Self._serviceList
			serviceProvider.stop()
		Next
	End Method


	' ------------------------------------------------------------
	' -- Updating / Rendering
	' ------------------------------------------------------------

	''' <summary>Update all services that provide an "update" method.</summary>
	''' <param name="delta">Number of milliseconds since the last update.</param>
	Method update(delta:Float = 0)
		For Local serviceProvider:GameService = EachIn Self._updateServices
			serviceProvider.update(delta)
		Next
	End Method

	''' <summary>Call the render method of all renderable services.</summary>
	''' <param name="delta">Number of milliseconds since the last render.</param>
	Method render(delta:Float = 0)
		For Local serviceProvider:GameService = EachIn Self._renderServices
			serviceProvider.render(delta)
		Next
	End Method


	' ------------------------------------------------------------
	' -- Manual injection
	' ------------------------------------------------------------

	''' <summary>
	''' Inject services into all registered services.
	'''
	''' This should be called once services have been registered so that they
	''' don't have to be added in a specific order.
	''' </summary>
	Method injectAllServices()
		For Local serviceProvider:GameService = EachIn Self._serviceList
			If serviceProvider.hasDependencies() Then
				For Local dependency:TTypeId = EachIn serviceProvider.getDependencies()
					serviceProvider.inject(dependency, Self.getService(dependency))
				Next
			EndIf
		Next
	End Method

	''' <summary>
	''' Autoload services into an object object from the kernel.
	'''
	''' If `requireAutoloadFlag` is true, fields that need injection must have
	''' the meta field "autoload_service".
	''' </summary>
	''' <param name="target">The target object to autoload.</param>
	''' <param name="requireAutoloadFlag">If true, service fields require "autoload_service" meta.</param>
	Method autoloadObjectServices(target:Object, requireAutoloadFlag:Byte = True)
		Local typeData:TTypeId = TTypeId.ForObject(target)
		Local baseType:TTypeId = TTypeId.ForName("GameService")

		For Local fieldData:TField = EachIn typeData.EnumFields()

			' Skip any field that doesn't have an autoload flag
			If requireAutoloadFlag And "" = fieldData.MetaData("autoload_service") Then Continue

			' Check this field is a service type
			Local fieldType:TTypeId = fielddata.TypeId()
			If fieldType = Null Then Continue

			' If this field type is a service, autoload it
			If Self._objectInherits(target, fieldType, baseType) Then
				fieldData.Set(target, Self.getService(fieldType))
			End If

		Next
	End Method

	''' <summary>
	''' Check if `fieldType` inherits `baseType`.
	'''
	''' This checks all parent types all the way to the root Object type.
	''' </summary>
	Method _objectInherits:Byte(target:Object, fieldType:TTypeId, baseType:TTypeId)
		If fieldType.ExtendsType(baseType) Then Return True
		If fieldType.SuperType() = Null Then Return False

		Return Self._objectInherits(target, fieldType.SuperType(), baseType)
	End Method


	' ------------------------------------------------------------
	' -- Service utility functions
	' ------------------------------------------------------------

	''' <summary>Apply function `fn` to all registered services.</summary>
	''' <param name="fn">The function to apply.</param>
	Method applyFunctionToServices(fn(s:Object))
		For Local s:GameService = EachIn Self.getServices()
			fn(s)
		Next
	End Method

	''' <summary>
	''' Check if a service provider implements a function by checking its
	''' "implements" meta data field.
	''' </summary>
	''' <param name="serviceProvider">The service to check.</param>
	''' <param name="functionName">Name to check for.</param>
	''' <returns>True if the service has this functionality, false if not.</returns>
	Function serviceImplements:Byte(serviceProvider:GameService, functionName:String)

		Local imp:String = TTypeId.ForObject(serviceProvider).MetaData("implements")
		Local methodList:String[] = imp.Split(",")

		For Local methodName:String = EachIn methodList
			methodName = methodName.Trim()
			If methodName = functionName Then Return True
		Next

		Return False

	End Function

	''' <summary>
	''' Called when a service has its priority changes. Re-sorts the service list
	''' by priority.
	''' </summary>
	Function _onPriorityChange:Object(id:Int, data:Object, context:Object)
		Local kernel:GameKernel = GameKernel(context)
		kernel.updatePriorities()
	End Function


	' ------------------------------------------------------------
	' -- Internal Helpers
	' ------------------------------------------------------------

	''' <summary>
	''' Add service to a collection if it implements a specific behaviour.
	'''
	''' This is an internal method used to add services to the render/update
	''' collections when needed.
	''' </summary>
	Method _addIfImplements(serviceProvider:GameService, imp:String, collection:GameServiceCollection)
		If Not GameKernel.serviceImplements(serviceProvider, imp) Then Return

		collection.add(serviceProvider, False)
		collection.sort(GameServiceCollection.SORT_ASC)
	End Method


	' ------------------------------------------------------------
	' -- Construction / Destruction
	' ------------------------------------------------------------

	Method New()

		' Create lookups and service collection
		Self._serviceLookup  = New GameServiceLocator
		Self._serviceList    = New GameServiceCollection
		Self._updateServices = New GameServiceCollection
		Self._renderServices = New GameServiceCollection

		' Set sort methods
		Self._updateServices.setSortMethod(SortUpdateableGameServiceObjects)
		Self._renderServices.setSortMethod(SortRenderableGameServiceObjects)

		' Set up ID allocation
		Self._nextServiceId	= 1

		' Listen for service priority changes
		AddHook(GameService.g_HookId, GameKernel._onPriorityChange, Self)

		' Add the information service
		Self.addService(Null, KernelInformationService.Create(Self))

	End Method

End Type
