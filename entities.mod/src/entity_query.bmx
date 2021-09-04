' ------------------------------------------------------------------------------
' -- src/entity_query.bmx
' --
' -- Flexible querying of entity collections. Not particularly speedy, but
' -- removes a lot of code duplication.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2019 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Include "query_filters/base_entity_query_filter.bmx"
Include "query_filters/component_type_entity_query_filter.bmx"
Include "query_filters/component_field_value_entity_query_filter.bmx"
Include "query_filters/group_name_entity_query_filter.bmx"

Type EntityQuery
	Field _filters:BaseEntityQueryFilter[]
	Field _toFilter:EntityBag

	' ------------------------------------------------------------
	' -- Configuring
	' ------------------------------------------------------------

	''' <summary>Set the collection of entities to filter.</summary>
	''' <param name="entities">EntityBag to filter</param>
	''' <return>Self</return>
	Method filter:EntityQuery(entities:EntityBag)
		Self._toFilter = entities

		Return Self
	End Method


	' ------------------------------------------------------------
	' -- Running Queries
	' ------------------------------------------------------------

	''' <summary>Run query filters and return the filtered collection.</summary>
	''' <return>EntityBag of filtered results.</return>
	Method getResults:EntityBag()
		If Self._toFilter = Null Then Return Null

		' Create a fast copy of the bag.
		Local results:EntityBag = Self._toFilter.copy()

		' Run filters.
		For Local filter:BaseEntityQueryFilter = EachIn Self._filters
			results = filter.filter(results)
		Next

		' Move all null values to the end.
		results.compact()

		Return results
	End Method

	''' <summary>Run query filters and return the number of items in the collection.</summary>
	''' <return>Number of items.</return>
	Method countResults:Int()
		Local results:EntityBag = Self.getResults()

		Return results.getSize()
	End Method

	''' <summary>Run query filters and return the first item found.</summary>
	''' <return>Entity that matches all filters.</return>
	Method getSingleResult:Entity()
		Local results:EntityBag = Self.getResults()

		Return results.get(0)
	End Method


	' ------------------------------------------------------------
	' -- Adding Filters
	' ------------------------------------------------------------

	''' <summary>Filter entity list to only include entities with a specific component.</summary>
	''' <remarks>Prefer using `EntityManager.getEntitiesWithComponent`.</remarks>
	''' <param name="t">The component type to filter by.</param>
	''' <return>Self</return>
	Method withComponent:EntityQuery(t:ComponentType)
		Return Self.addFilter(ComponentTypeEntityQueryFilter.Create(t))
	End Method

	''' <summary>Filter entity list to only include entities without a specific component.</summary>
	''' <param name="t">The component type to filter by.</param>
	''' <return>Self</return>
	Method withoutComponent:EntityQuery(t:ComponentType)
		Return Self.addFilter(ComponentTypeEntityQueryFilter.Create(t, True))
	End Method

	''' <summary>Filter entity list to only include entities with a specific field value.</summary>
	''' <param name="t">The component to check.</param>
	''' <param name="name">The component field to check.</param>
	''' <param name="value">The value to check.</param>
	''' <return>Self</return>
	Method withComponentFieldValue:EntityQuery(t:ComponentType, name:String, value:Object)
		Return Self.addFilter(ComponentFieldValueEntityQueryFilter.Create(t, name, value))
	End Method

	Method withoutComponentFieldValue:EntityQuery(t:ComponentType, fieldName:String, fieldValue:Object)
		Throw "Not yet implemented"
        ' Self.addFilter(ComponentFieldNotValueEntityQueryFilter.Create(t, fieldName, fieldValue))

		Return Self
	End Method

	''' <summary>Filter entity list to only include entities with a specific group.</summary>
	''' <remarks>Prefer using `GroupManager.getEntities`.</remarks>
	''' <param name="group">The group name to filter by.</param>
	''' <return>Self</return>
	Method withGroup:EntityQuery(group:String)
		Return Self.addFilter(GroupNameEntityQueryFilter.Create(group))
	End Method

	''' <summary>Add a filter to the query.</summary>
	''' <param name="filter">The filter to add.</param>
	''' <return>Self</return>
	Method addFilter:EntityQuery(filter:BaseEntityQueryFilter)
		Self._filters = Self._filters[..Self._filters.Length + 1]
		Self._filters[Self._filters.Length - 1] = filter

		Return Self
	End Method


	' ------------------------------------------------------------
	' -- Construction
	' ------------------------------------------------------------

	''' <summary>Create a new EntityQuery and set the list of entities to filter.</summary>
	Function Create:EntityQuery(entities:EntityBag)
		Local this:EntityQuery = New EntityQuery

		this._toFilter = entities

		Return this
	End Function
End Type
