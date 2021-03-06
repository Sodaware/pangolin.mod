' ------------------------------------------------------------------------------
' -- src/component_type_mapper.bmx
' --
' -- Static type that maps the TTypeId for a component type to a type bit.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Import brl.map
Import brl.reflection

Import "component_type.bmx"

''' <summary>
''' Static type that maps the TTypeId for a component its static type data.
''' </summary>
Type ComponentTypeMapper
	Global _componentTypes:TMap = New TMap

	Function getTypeFor:ComponentType(t:TTypeId)
		Local found:ComponentType = ComponentType(ComponentTypeMapper._componentTypes.ValueForKey(t))

		If found = Null Then
			found = New ComponentType
			ComponentTypeMapper._componentTypes.Insert(t, found)
		End If

		Return found
	End Function

	Function getId:Int(t:TTypeId)
		Return ComponentTypeMapper.getTypeFor(t).getId()
	End Function

	Function getBit:Byte(t:TTypeId)
		Return ComponentTypeMapper.getTypeFor(t).getBit()
	End Function
End Type
