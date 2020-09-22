' ------------------------------------------------------------------------------
' -- src/resource_events.bmx
' --
' -- Events that are used by the resource manager.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2020 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


''' <summary>Base type that all resource-related events extend.</summary>
Type ResourceEvent Extends GameEvent

End Type

''' <summary>
''' Event that is emitted during resource manifest actions.
'''
''' These are usually emitted when loading of the resource manifest starts and
''' it finishes.
''' </summary>
Type ResourceManifestEvent Extends ResourceEvent
	Field _file:String
	Field _loader:ResourceFileSerializer

	''' <summary>Get the file name of the resource manifest.</summary>
	Method getFilename:String()
		Return Self._file
	End Method

	''' <summary>Get the serializer that is loading the manifest.</summary>
	Method getLoader:ResourceFileSerializer()
		Return Self._loader
	End Method

	''' <summary>Build a ResourceManifestEvent.</summary>
	''' <param name="file">The name of the manifest file.</param>
	''' <param name="loader">The serializer that is loading the manifest.</param>
	''' <param name="name">The event name (e.g. "load_started" or "load_finished")</param>
	Function Build:ResourceManifestEvent(file:String, loader:ResourceFileSerializer, name:String = "")
		Local this:ResourceManifestEvent = New ResourceManifestEvent

		this._file   = file
		this._loader = loader
		this.name    = name

		Return this
	End Function
End Type

''' <summary>Event that is emitted when a resource (BaseResource) is loaded.</summary>
Type ResourceLoadedEvent Extends ResourceEvent
	Field _resource:BaseResource

	''' <summary>Get resource that was loaded.</summary>
	Method getResource:BaseResource()
		Return Self._resource
	End Method

	''' <summary>Build a ResourceLoadedEvent.</summary>
	''' <param name="resource">The resource that was loaded.</param>
	Function Build:ResourceLoadedEvent(resource:BaseResource)
		Local this:ResourceLoadedEvent = New ResourceLoadedEvent

		this.name      = "resource_loaded"
		this._resource = resource

		Return this
	End Function
End Type
