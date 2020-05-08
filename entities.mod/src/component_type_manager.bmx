' ------------------------------------------------------------------------------
' -- src/component_type_manager.bmx
' --
' -- Static type that maps ComponentType objects to TTypeId. This is a static
' -- type because BlitzMax Type information cannot be changed at runtime.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Import brl.map
Import brl.reflection

Import "component_type.bmx"

''' <summary>
''' Static type that maps ComponentType objects to TTypeId. This is a static
''' type because BlitzMax type information cannot be changed at runtime.
''' </summary>
Type ComponentTypeManager

	''' <summary>Map of TTypeId to ComponentType objects.</summary>
	Global _componentTypes:TMap = New TMap

	''' <summary>Map of meta names to ComponentType objects.</summary>
	Global _componentTypesMeta:TMap


	' ------------------------------------------------------------
	' -- Getting Types
	' ------------------------------------------------------------

	''' <summary>Get the ComponentType for a BlitzMax TTypeId.</summary>
	Function getTypeFor:ComponentType(t:TTypeId)
		If t = Null Then Throw "Cannot get ComponentType for Null TTypeId"
		Local found:ComponentType = ComponentType(ComponentTypeManager._componentTypes.ValueForKey(t))

		If found = Null Then
			found = New ComponentType

			found._name = t.Name()
			ComponentTypeManager._componentTypes.Insert(t, found)
		End If

		Return found
	End Function

	''' <summary>Get the ComponentType for a Type name.</summary>
	''' <param name="name">A valid BlitzMax type name.</param>
	Function getTypeForName:ComponentType(name:String)
		Return ComponentTypeManager.getTypeFor(TTypeId.ForName(name))
	End function

	''' <summary>Get the ComponentType for a component's meta name.</summary>
	Function getTypeForMetaName:ComponentType(name:String)
		Return ComponentTypeManager.getTypeFor(ComponentTypeManager._getTypeForMeta(name))
	End Function

	Function getBit:Long(t:TTypeId)
		Return ComponentTypeManager.getTypeFor(t).getBit()
	End Function

	Function getId:Int(t:TTypeId)
		Return ComponentTypeManager.getTypeFor(t).getId()
	End Function


	' ------------------------------------------------------------
	' -- Autoload Helpers
	' ------------------------------------------------------------

	''' <summary>
	''' Set field values of an object to ComponentType instances via metadata.
	'''
	''' This is used for setting lookup fields in a type. It's the equivelant of
	''' manually calling `ComponentTypeManager.getTypeForName`, but uses metadata
	''' to simplify things.
	'''
	''' For example:
	''' `Field component_lookup:ComponentType { component_type = "MyComponent" }`
	'''
	''' Will set the `component_lookup` field to be the component type for
	''' "MyComponent".
	''' </summary>
	''' <param name="o">The object to autoload fields for.</param>
	Function autoloadTypeLookups(o:Object)
		Local objectInfo:TTypeId = TTypeId.ForObject(o)

		For Local f:TField = EachIn objectInfo.EnumFields()
			If f.MetaData("component_type") <> Null Then
				f.Set(Self, ComponentTypeManager.getTypeForName(f.MetaData("component_type")))
			EndIf
		Next
	End Function


	' ------------------------------------------------------------
	' -- Internal Helpers
	' ------------------------------------------------------------

	Function _getTypeForMeta:TTypeId(metaName:String)

		' Load types
		If ComponentTypeManager._componentTypesMeta = Null Then
			ComponentTypeManager._initializeMetaLookup()
		End If

		Local t:TTypeId = TTypeId(ComponentTypeManager._componentTypesMeta.ValueForKey(metaName))
		If t = Null Then
			DebugLog "Could not find TTypeId for " + metaName
			Return Null
		End If

		Return t

	End Function

	Function _initializeMetaLookup()

		' Create map of meta_name => ComponentType
		ComponentTypeManager._componentTypesMeta = New TMap
		Local baseType:TTypeId = TTypeId.ForName("EntityComponent")
		For Local childType:TTypeId = EachIn baseType.DerivedTypes()
			If childType.MetaData("name") = Null Then Throw "Type " + childType.Name() + " is missing ~qname~q metadata"

			ComponentTypeManager._componentTypesMeta.Insert(childType.MetaData("name"), childType)
		Next

	End Function

End Type
