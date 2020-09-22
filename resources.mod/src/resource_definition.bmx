' ------------------------------------------------------------------------------
' -- src/resource_definition.bmx
' --
' -- The definition for a single resource. Used as a way to abstract resource
' -- information away from a single file format so resources can be loaded
' -- from anything, such as YAML, JSON or XML.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.linkedlist
Import brl.map

Import sodaware.stringtable

Type ResourceDefinition

	Field _name:String                  '''< Resource name.
	Field _namespace:String             '''< Resource namespace.
	Field _fileName:String              '''< Optional resource file name.
	Field _resourceType:String          '''< The resource type.
	Field _details:StringTable          '''< Map of field names => values.
	Field _data:TMap                    '''< Additional map of freeform data.
	Field _skipAutoload:Byte = False    '''< If true, resource will not be autoloaded.


	' ------------------------------------------------------------
	' -- Retrieving Information
	' ------------------------------------------------------------

	''' <summary>Get the name of the resource.</summary>
	''' <return>Resource name.</return>
	Method getName:String()
		Return Self._name
	End Method

	''' <summary>Get the full name of the resource, including its namespace.</summary>
	''' <return>Full name in the format `{namespace}.{name}`.</return>
	Method getFullName:String()
		If Self._namespace = "" Then Return Self._name

		Return Self._namespace + "." + Self._name
	End Method

	''' <summary>Get the resource type.</summary>
	''' <return>Resource type.</return>
	Method getType:String()
		Return Self._resourceType
	End Method

	''' <summary>
	''' Get the resource file name.
	'''
	''' This is the location where the resource is stored.
	''' </summary>
	''' <return>Resource file name.</summary>
	Method getFileName:String()
		Return Self._fileName
	End Method

	''' <summary>
	''' Check if autoloading is disabled.
	'''
	''' When autoloading is disabled, resources are not loaded until they are
	''' requested.
	''' </summary>
	''' <return>True if autoloading is disabled, false if not.</return>
	Method skipAutoload:Byte()
		Return Self._skipAutoload
	End Method


	' ------------------------------------------------------------
	' -- Getting / Setting extra fields
	' ------------------------------------------------------------

	''' <summary>
	''' Add a field to the definition.
	'''
	''' This should only be called when a resource definition is being loaded
	''' (i.e. from within a serializer).
	''' </summary>
	''' <param name="fieldName">The field to set.</param>
	''' <param name="value">The value of the field.</param>
	Method addField(fieldName:String, value:String)
		Self._details.set(fieldName, value)
	End Method


	''' <summary>Get the value of a field from the definition.</summary>
	''' <param name="fieldName">The field to get.</param>
	''' <param name="defaultValue">Optional value that will be returned if field is empty.</param>
	''' <return>The field value.</return>
	Method getField:String(fieldName:String, defaultValue:String = "")
		If Self._details.ValueForKey(fieldName) = Null Then Return defaultValue

		Return Self._details.get(fieldName)
	End Method


	' ------------------------------------------------------------
	' -- Getting Data
	' ------------------------------------------------------------

	Method getData:Tmap(name:String)
		Return TMap(Self._data.ValueForKey(name))
	End Method

	Method getDataFields:TList()
		' TODO: Add some caching here!!!!
		Local fields:TList = New TList
		For Local key:String = EachIn Self._data.Keys()
			fields.AddLast(key)
		Next
		Return fields
	End Method


	' ------------------------------------------------------------
	' -- Construction / Destruction
	' ------------------------------------------------------------

	Method New()
		Self._details = New StringTable
		Self._data    = New TMap
	End Method

End Type
