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

	Method canLoad:Byte(fileName:String) Abstract
	Method load(db:ContentDb, url:Object) Abstract
	Method loadEntities:TList(db:ContentDb, url:Object) Abstract
	Method save(db:ContentDb, url:Object) Abstract

	Method _openFile:TStream(url:Object)

		' Attempt to read map stream
		Local fileIn:TStream = ReadStream(url)
		If Not(fileIn) Then Return Null

		' Check position in stream is correct
		If fileIn.Pos() = -1
			fileIn.Close()
			Return Null
		EndIf

		Return fileIn

	End Method

End Type
