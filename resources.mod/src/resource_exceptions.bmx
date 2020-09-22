' ------------------------------------------------------------------------------
' -- src/resource_exceptions.bmx
' --
' -- Exceptions for the resource manager system.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2020 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.filesystem

Type ResourceException Extends TBlitzException

End Type

Type MissingResourceException Extends ResourceException
	Field _resource:String

	Method toString:String()
		Return "Resource named ~q" + Self._resource + "~q does not exist in the resource manager"
	End Method

	Function Create:MissingResourceException(resource:String)
		Local exception:MissingResourceException = New MissingResourceException

		exception._resource = resource

		Return exception
	End Function
End Type

Type InvalidResourceTypeException Extends ResourceException
	Field _type:String

	Method toString:String()
		Return "Resource type ~q" + Self._type + "~q does not exist"
	End Method

	Function Create:InvalidResourceTypeException(typeName:String)
		Local exception:InvalidResourceTypeException = New InvalidResourceTypeException

		exception._type = typeName

		Return exception
	End Function
End Type

Type MissingResourceSerializerException Extends ResourceException
	Field _filename:String

	Method toString:String()
		Return "No resource serializer found for type: " + ExtractExt(Self._filename)
	End Method

	Function Create:MissingResourceSerializerException(file:String)
		Local exception:MissingResourceSerializerException = New MissingResourceSerializerException

		exception._filename = file

		Return exception
	End Function
End Type
