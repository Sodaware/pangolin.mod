' ------------------------------------------------------------------------------
' -- src/serializers/component_schema_serializer.bmx
' --
' -- Base type for serializing a component schema.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type ComponentSchemaSerializer

	Method canLoad:Byte(fileName:String) Abstract
	Method loadComponentSchema:TList(fileName:String) Abstract

End Type
