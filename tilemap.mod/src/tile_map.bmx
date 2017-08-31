' ------------------------------------------------------------------------------
' -- src/tile_map.bmx
' --
' -- A tilemap is made up of a number of layers, each of which contains a list
' -- of tile id's. Tileset data is stored separately in the TileSet object.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.map
Import brl.bank


Type TileMap
	
	' -- Map info
	Field _layerCount:Int		''' Number of layers
	Field _width:Int			''' Width of the map in tiles
	Field _height:Int			''' Height of the map in tiles

	' -- Meta
	Field _metaData:TMap		''' Meta data, such as tileset name
	
	 ' -- Internal fields
 	Field _mapData:TBank		''' Bank of tile ID's
	Field _layerOffset:Int		''' Internal memory offset for each layer
	
	
	' ------------------------------------------------------------
	' -- Public access methods
	' ------------------------------------------------------------
	
	''' <summary>Get the ID of a tile using its full position.</summary> 
	Method getTile:Short(layer:Int, xPos:Int, yPos:Int)
		
		' Check inputs
		If layer < 0 Or layer >= Self._layerCount Then Return -1
		If xPos < 0 Or xPos >= Self._width Then Return -1
		If yPos < 0 Or yPos >= Self._height Then Return -1
		
		' Get tile ID
		Return Self._mapData.PeekShort((layer * Self._layerOffset) + (((yPos * Self._width) + xPos) Shl 1))
		
	End Method
	
	' TODO: REWRITE THIS!
	Method countMetaFields:Int()
		Local count:Int = 0
		For Local a:Object = EachIn Self._metaData.Keys()
			count:+ 1
		Next
		Return count
	End Method
	
	Method getMetaKeys:TMapEnumerator()
		Return Self._metaData.Keys()
	End Method
	
	Method getHeight:Int() 
		Return Self._height
	End Method
	
	Method getWidth:Int()
		Return Self._width
	End Method
	
	Method getMeta:String(fieldName:String)
		Return String(Self._metaData.ValueForKey(fieldName))
	End Method
	
	Method countLayers:Int()
		Return Self._layerCount
	End Method
		
	
	' ------------------------------------------------------------
	' -- Public setters
	' ------------------------------------------------------------

	Method setTile:Byte(layer:Int, xPos:Int, yPos:Int, tileID:Int)
		
		' Check inputs
		If layer < 0 Or layer >= Self._layerCount Then Return False
		If xPos < 0 Or xPos >= Self._width Then Return False
		If yPos < 0 Or yPos >= Self._height Then Return False
		If tileID < 0 Then Return False
		
		' Set the tile
		Self._mapData.PokeShort((layer * Self._layerOffset) + (((yPos * Self._width) + xPos) Shl 1), tileID)
		Return True
		
	End Method

	Method fillRange(layer:Int, xPos:Int, yPos:Int, width:Int, height:Int, tileID:Short)
		For Local x:Int = xPos To xPos + width
			For Local y:Int	= yPos To yPos + height
				self.setTile(layer, x, y, tileID)
			Next
		Next
	End Method
	
	Method addLayer()
		
	End Method
	
	Method insertLayer(position:Int)
	End Method
	
	Method removeLayer(layerID:Int)
		
	End Method
	
	
	
	Method setMeta(fieldName:String, fieldData:String)
		Self._metaData.Insert(fieldName, fieldData)
	End Method

	
	' ------------------------------------------------------------
	' -- Creation & Initialisation
	' ------------------------------------------------------------
	
	Function Create:TileMap(width:Short, height:Short, layers:Short)
		
		' -- Check inputs
		If width < 1 Or height < 1 Or layers < 1 Then Return Null
		
		Local this:TileMap = New TileMap
		
		this._width      = width
		this._height     = height
		this._layerCount = layers
		
		this._initialiseMapData()
		
		Return this
		
	End Function
	
	Method New()
		Self._metaData = New TMap
	End Method
	
	Method _initialiseMapData()
		' TODO: Check inputs
	
		' Clear old data
		Self._mapData = Null
		
		' used to calculate offset
		Local s:Short
		
		Self._layerOffset = Self._height * Self._width * SizeOf(s)
		Self._mapData = TBank.Create(Self._layerCount * Self._layerOffset)
		
	End Method
	
End Type
