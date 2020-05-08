' ------------------------------------------------------------------------------
' -- src/tile_set.bmx
' --
' -- Tilesets contain data for a collection of tiles. Individual tile data is
' -- stored in a Tile object, or AnimatedTile object for animated tiles.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.reflection
Import brl.stream
Import brl.max2d
Import brl.map

Import "tile.bmx"
Import "animated_tile.bmx"

Type TileSet
	
	Field _imageName:String
	Field _tileWidth:Int						'''< The width of a single tile
	Field _tileHeight:Int						'''< The height of a single tile

	Field _tiles:TList
	Field _animatedTiles:TList

	Field _tileLookup:Tile[]
	Field _animatedTileLookup:AnimatedTile[]
	
	Field _metaData:TMap
	
	Field _tileCount:Int
	Field _animatedTileCount:Int
	
	
	' ------------------------------------------------------------
	' -- Public getters
	' ------------------------------------------------------------

	Method getTileWidth:int()
		Return Self._tileWidth
	End Method

	Method getTileHeight:int()
		Return Self._tileHeight
	End Method
	
	Method getMeta:String(fieldName:String)
		Return String(Self._metaData.ValueForKey(fieldName))
	End Method
	
	Method getAnimatedTiles:TList()
		Return Self._animatedTiles
	End Method
	
	Method countTiles:Int()
		Return Self._tiles.Count()
	End Method
	
	Method countAnimatedTiles:Int()
		Return Self._animatedTiles.Count()
	End Method
	
	Method getTileInfo:Tile(tileID:Int)
		' TODO: Cache these values.
		If tileID = -1 Then Return Null

		' TODO: Gets information about a set tile
		If tileID > -1 And tileID < Self._tileCount Then
			Return Self._tileLookup[tileID]
		Else
			If tileID - Self._tileCount >= Self._animatedTileCount Then Return Null
			Return Self._animatedTileLookup[tileID - Self._tileLookup.Length]
		EndIf
	End Method
	
	' TODO: REWRITE THIS!
	Method countMetaFields:Int()
		Local count:Int = 0
		For Local a:Object = EachIn Self._metaData.Keys()
			count:+ 1
		Next
		Return count
	End Method	
	
	Method setMeta(fieldName:String, fieldData:String)
		Self._metaData.Insert(fieldName, fieldData)
	End Method
	
	Method tileIsAnimated:Byte(tileId:Int)
	
		' TODO: Cache a list of animated ids instead
		Return "" <> String(Self.getTileInfo(tileId).getMeta("animation_name"))
		
	End Method
	
	' ----- Access methods
	
	' Returns ID of tile added, or -1 on fail
	Method addTile:Int(tileObject:Tile)
		If tileObject = Null Then Return -1 
		Self._tiles.AddLast(tileObject)
		Return Self._tiles.Count() - 1
	End Method
	
	Method addAnimatedTile:Int(tileObject:AnimatedTile)
		If tileObject = Null Then Return -1
		Self._animatedTiles.AddLast(tileObject)
		Return Self._animatedTiles.Count() - 1
	End Method
	
	''' <summary>Rebuild internal lookups.</summary>
	Method _updateInternals()
		
		Self._tileCount             = Self._tiles.Count()
		Self._animatedTileCount     = Self._animatedTiles.Count()
	
		Self._tileLookup			= New Tile[Self._tileCount]
		Self._animatedTileLookup	= New AnimatedTile[Self._animatedTileCount]
		
		' Create tile lookup
		For Local offset:Int = 0 To Self._tileCount - 1
			Self._tileLookup[offset] = Tile(Self._tiles.ValueAtIndex(offset))			
		Next
		
		' Create animated tile lookup
		For Local offset:Int = 0 To Self._animatedTileCount - 1
			Self._animatedTileLookup[offset] = AnimatedTile(Self._animatedTiles.ValueAtIndex(offset))
		Next
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Creation & Initialisation
	' ------------------------------------------------------------
	
	Method New()
		Self._metaData       = New TMap
		Self._tiles         = New TList
		Self._animatedTiles = New TList
	End Method
	
	Function Create:TileSet()
		Return New TileSet
	End Function
	
End Type
