' ------------------------------------------------------------------------------
' -- src/serializers/base_tilemap_serializer.bmx
' --
' -- Base type all tilemap serializers must extend.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../tile_map.bmx"

Type BaseTileMapSerializer
	Method Load:TileMap(fileIn:TStream) Abstract
	Method Save(fileOut:TStream, map:TileMap) Abstract
End Type
