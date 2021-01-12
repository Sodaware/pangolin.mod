' ------------------------------------------------------------------------------
' -- src/query_filters/component_type_entity_query_filter.bmx
' --
' -- Query filter for limiting a collection to specific component types.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2019 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


''' <summary>Filter a list of entities by component type.</summary>
Type ComponentTypeEntityQueryFilter extends BaseEntityQueryFilter
	Field _componentType:ComponentType
	Field _invert:Byte = False

	Method filter:EntityBag(bag:EntityBag)
		Local size:Int          = bag._size - 1
		Local hasComponent:Byte = False

		For Local i:Int = 0 To size
			If bag._objects[i] = Null Then Continue

			' TODO: Optimize this
			hasComponent = bag._objects[i].hasComponent(Self._componentType)
'			hasComponent = bag._objects[i]._typeBits & Self._componentType._bit = Self._componentType._bit 			

			Select Self._invert
				Case True
					' Remove if entity has this component.
					If hasComponent Then bag._objects[i] = Null
				Case False
					' Remove if entity DOES NOT have this component.
					If Not hasComponent Then bag._objects[i] = Null
			End Select
		Next

		Return bag
	End Method

	Function Create:ComponentTypeEntityQueryFilter(t:ComponentType, invert:Byte = false)
		Local this:ComponentTypeEntityQueryFilter = new ComponentTypeEntityQueryFilter

		this._componentType = t
		this._invert        = invert

		Return this
	End Function
End Type
