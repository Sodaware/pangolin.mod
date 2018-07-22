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

Import brl.map
Import brl.linkedlist

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

	Method getName:String()
		Return Self._name
	End Method

	Method getFullName:String()
		If Self._namespace = "" Then Return Self._name
		Return Self._namespace + "." + Self._name
	End Method

	Method getType:String()
		Return Self._resourceType
	End Method

	Method getFileName:String()
		Return Self._fileName
	End Method

	Method skipAutoload:Byte()
		Return Self._skipAutoload
	End Method


	' ------------------------------------------------------------
	' -- Getting / Setting extra fields
	' ------------------------------------------------------------

	Method addField(fieldName:String, value:String)
		Self._details.set(fieldName, value)
	End Method

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
