' ------------------------------------------------------------------------------
' -- src/exceptions.bmx
' --
' -- Exceptions for the entity system.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2020 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type EntitySystemException Extends TBlitzException

End Type

Type MissingEntityComponentException Extends EntitySystemException
	Field _entity:Entity
	Field _component:ComponentType

	Method toString:String()
		Local message:String = ""

		message :+ "Entity `" + Self._entity.getTag() + "`"
		message :+ " missing required component "
		message :+ "`" + Self._component.getName() + "`"

		Return message
	End Method

	Function Create:MissingEntityComponentException(e:Entity, c:ComponentType)
		Local exception:MissingEntityComponentException = New MissingEntityComponentException

		exception._entity    = e
		exception._component = c

		Return exception
	End Function
End Type
