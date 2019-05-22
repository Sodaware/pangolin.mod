' ------------------------------------------------------------------------------
' -- src/serializers/content_db_serializer.bmx
' --
' -- Base type for serializing an entire content database.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type ContentDbSerializer

	Method CanLoad:Int(fileName:String) Abstract
	Method Load(db:ContentDb, url:Object) Abstract
	Method loadEntities:TList(db:ContentDb, url:Object) Abstract
	Method Save(db:ContentDb, url:Object) Abstract

	Method _openFile:TStream(url:Object)

		' Attempt to read map stream
		Local fileIn:TStream = ReadStream( url )
		If Not(fileIn) Then Return Null

		' Check position in stream is correct
		If fileIn.Pos() = -1
			fileIn.Close()
			Return Null
		EndIf

		Return fileIn

	End Method

End Type
