' ------------------------------------------------------------------------------
' -- src/services/game_service_locator.bmx
' --
' -- Maps service types to their instances. i.e. TTypeId => GameService.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

import brl.map

Import "../services/game_service.bmx"

''' <summary>
''' Maps service types to their instances. i.e. TTypeId => GameService. Works in
''' exactly the same way as a tmap, except the keys and values are strongly-typed
''' and automatically casted.
''' </summary>
Type GameServiceLocator extends TMap

	''' <summary>Get a GameService from the locator.</summary>
	Method get:GameService(serviceType:TTypeId)
		Return GameService(Self.ValueForKey(serviceType))
	End Method

	''' <summary>Add a service to the locator.</summary>
	''' <param name="serviceType">The service type to set.</param>
	''' <param name="serviceInstance">The service instance to set.</param>
	Method set:GameServiceLocator(serviceType:TTypeId, serviceInstance:GameService)
		Self.Insert(serviceType, serviceInstance)
	End Method

	''' <summary>Remove a service from the locator.</summary>
	Method unset(serviceType:TTypeId)
		Self.Remove(serviceType)
	End Method

End Type
