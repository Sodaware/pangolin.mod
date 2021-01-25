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

''' <summary>
''' Exception that is thrown if an entity is missing a required component.
''' </summary>
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

Type InvalidWorldInstanceException Extends EntitySystemException
	Method toString:String()
		Return "Entity must belong to a valid World instance."
	End Method
End Type

Type InvalidSystemTypeException Extends EntitySystemException
	Field _systemType:TTypeId

	Method toString:String()
		Return "System type `" + Self._systemType.Name() + "` does not extend EntitySystem"
	End Method

	Function Create:InvalidSystemTypeException(t:TTypeId)
		Local exception:InvalidSystemTypeException = New InvalidSystemTypeException

		exception._systemType = t

		Return exception
	End Function
End Type
