' ------------------------------------------------------------------------------
' -- src/query_filters/group_name_entity_query_filter.bmx
' --
' -- Query filter for limiting a collection by field values.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2019 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


''' <summary>Filter a list of entities by group name</summary>
Type GroupNameEntityQueryFilter extends BaseEntityQueryFilter
	Field _groupName:String

	Method filter:EntityBag(bag:EntityBag)
		Local size:Int = bag._size - 1

		For Local i:Int = 0 To size
			If bag._objects[i] = Null Or Self._groupName <> bag._objects[i].getGroup() Then
				bag._objects[i] = Null
			EndIf
		Next

		Return bag
	End Method

	Function Create:GroupNameEntityQueryFilter(group:String)
		Local this:GroupNameEntityQueryFilter = new GroupNameEntityQueryFilter

		this._groupName = group

		Return this
	End Function
End Type
