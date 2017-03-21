' ------------------------------------------------------------------------------
' -- src/serializers/base_tileset_serializer.bmx
' -- 
' -- Base type for all tileset serializers.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------

SuperStrict

Import "../tile_set.bmx"

Type BaseTileSetSerializer
	Method Load:TileSet(fileIn:TStream) Abstract
	Method Save(fileOut:TStream, set:TileSet) Abstract
End Type
