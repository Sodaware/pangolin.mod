' ------------------------------------------------------------------------------
' -- Pangolin.Entities -- entity_component.bmx
' -- 
' -- Base class that all entity components must extend.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type EntityComponent
	
	Field _parent:Entity
	
	' ------------------------------------------------------------
	' -- Optional Hooks
	' ------------------------------------------------------------

	''' <summary>
	''' Called when a component has been created but before additional 
	''' data has been set.
	''' </summary>
	Method beforeCreate()
	End Method
	
	''' <summary>
	''' Called after the component has been created and had its data
	''' loaded.
	''' </summary>
	Method afterCreate()
	End Method
	
	''' <summary>Called when the entity this component is attached to has been deleted.</summary>
	Method onDelete()
	End Method
	
	''' <summary>Called when component has been removed from an entity.</summary>
	Method onRemove()
		
	End Method
	
End Type
