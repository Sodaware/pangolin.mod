' ------------------------------------------------------------------------------
' -- src/base_resource.bmx
' --
' -- The base type for all game resources. All resources (images, sounds etc)
' -- should inherit from this and contain the following:
' --
' --  * Creation from a ResourceDefinition
' --  * A "_load" method to load / reload the resource
' --  * A "_free" method to delete internal resources
' --  * A "_loadDefinition" method to load the resource's definition
' --  * A "_getHandle" method that returns internal resource data
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "resource_definition.bmx"

Type BaseResource Abstract

	Field _definition:ResourceDefinition    '''< Definition of resource.
	Field _name:String                      '''< Identifier for this resource.
	Field _isLoaded:Byte                    '''< True if resource loaded, false if not.
	Field _referenceCount:Int               '''< Number of places resource is referenced.


	' ------------------------------------------------------------
	' -- Public API
	' ------------------------------------------------------------

	''' <summary>Get the full name of the resource.</summary>
	Method getName:String()
		Return Self._definition.getFullName()
	End Method

	''' <summary>Get the full filename of the resource.</summary>
	''' <return>The complete filename and path.</return>
	Method getFileName:String()
		Return Self._definition.getFileName()
	End Method

	''' <summary>
	''' Get handle of actual resource. Call this instead of _get, as
	''' _get DOES NOT load the resource.
	''' </summary>
	''' <return>Returns an object. Depends on sub-class.</return>
	Method get:Object()
		If Self._isLoaded = False Then Self.reload()

		Return Self._get()
	End Method

	''' <summary>Get number of places resource is references.</summary>
	Method getReferenceCount:Int()
		Return Self._referenceCount
	End Method

	''' <summary>Get complete definition of resource.</summary>
	''' <return>ResourceDefinition for this resource.</return>
	Method getDefinition:ResourceDefinition()
		Return Self._definition
	End Method

	Method reload()
		Self._isLoaded = True
		Self._load()
	End Method

	Method free()
		Self._decreaseCount
		If Self._referenceCount = 0 Then Self._free()
	End Method


	' ------------------------------------------------------------
	' -- Abstract Methods
	' ------------------------------------------------------------

	Method _load()				Abstract
	Method _free()				Abstract
	Method _get:Object()		Abstract
	Method _loadDefinition()	Abstract


	' ------------------------------------------------------------
	' -- Internal API
	' ------------------------------------------------------------

	''' <summary>Increase the number of references to object.</summary>
	Method _increaseCount()
		Self._referenceCount:+ 1
	End Method

	''' <summary>Decrease the number of references to object.</summary>
	Method _decreaseCount()
		Self._referenceCount:- 1
	End Method


	' ------------------------------------------------------------
	' -- Initialization
	' ------------------------------------------------------------

	''' <summary>Initialises a resource from a ResourceDefinition object.</summary>
	Method init(def:ResourceDefinition)
		Self._definition = def
		Self._loadDefinition()
	End Method

End Type
