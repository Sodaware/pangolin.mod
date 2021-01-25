' ------------------------------------------------------------------------------
' -- src/soda_resource_file_serializer.bmx
' --
' -- Adds support for loading resource definitions using the SODA file format.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.TileMap

Import sodaware.file_soda


Type SodaTilesetSerializer Extends TilesetSerializer

	''' <summary>Load the tileset data</summary>
	Method Load:TileSet(fileIn:TStream)

		' Load the soda document
		Local tilesetDoc:SodaFile = SodaFile.LoadFromStream(fileIn)

		' Check it was read
		If tilesetDoc = Null Throw "Could not load tileset"

		' Create the new set
		Local set:TileSet = New TileSet

	End Method

End Type