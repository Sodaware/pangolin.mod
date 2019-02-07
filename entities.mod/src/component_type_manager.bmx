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

	Function getTypeFor:ComponentType(t:TTypeId)

		If t = Null Then Throw "Cannot get ComponentType for Null TTypeId"
		Local found:ComponentType = ComponentType(ComponentTypeManager._componentTypes.ValueForKey(t))

		If found = Null Then
			found = New ComponentType
			ComponentTypeManager._componentTypes.Insert(t, found)
		End If

		Return found

	End Function

	Function getTypeForName:ComponentType(name:String)
		Return ComponentTypeManager.getTypeFor(TTypeId.ForName(name))
	End function

	Function getTypeForMetaName:ComponentType(name:String)
		Return ComponentTypeManager.getTypeFor(ComponentTypeManager._getTypeForMeta(name))
	End Function

	Function getBit:Long(t:TTypeId)
		Return ComponentTypeManager.getTypeFor(t).getBit()
	End Function

	Function getId:Int(t:TTypeId)
		Return ComponentTypeManager.getTypeFor(t).getId()
	End Function

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
