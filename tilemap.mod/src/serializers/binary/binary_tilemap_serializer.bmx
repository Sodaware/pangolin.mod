' ------------------------------------------------------------------------------
' -- src/serializers/binary/binary_tilemap_serializer.bmx
' --
' -- Binary serializer for tilemaps. Binary tilemaps are fast to load but 
' -- aren't stored in human-friendly format.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../base_tilemap_serializer.bmx"

Type BinaryTileMapSerializer Extends BaseTileMapSerializer
	
	Const HEADER:String = "PM"

	' ------------------------------------------------------------
	' -- Load & Save
	' ------------------------------------------------------------

	Method Load:TileMap(fileIn:TStream)
		
		' Check the header
		If fileIn.ReadString(HEADER.Length) <> HEADER Then Return Null
	
		Local width:Short  = fileIn.ReadShort()
		Local height:Short = fileIn.ReadShort()
		Local layers:Short = fileIn.ReadShort()
		
		Local map:TileMap	= TileMap.Create(width, height, layers)
		
		' Read layers & meta data
		Self._readLayers(fileIn, map)
		Self._readMetaData(fileIn, map)
		
		Return map
	
	End Method
	
	Method Save(fileOut:TStream, map:TileMap)
		
		' Write header
		fileOut.WriteString(HEADER)
		
		' Write dimensions
		fileOut.WriteShort(map.getWidth())
		fileOut.WriteShort(map.getHeight())
		fileOut.WriteShort(map.countLayers())
		
		' Write layers & meta data
		Self._writeLayers(fileOut, map)
		Self._writeMetaData(fileOut, map)
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Internal load methods
	' ------------------------------------------------------------
	
	Method _readLayers(fileIn:TStream, map:TileMap)
		
		' Read layers
		For Local layer:Short = 0 To map.countLayers() - 1
			
			' Read each layer
			Local offset:Int = map._layerOffset * layer
			
			For Local yPos:Short = 1 To map._width
				For Local xPos:Short = 1 To map._height
					map._mapData.PokeShort(offset, fileIn.ReadShort())
					offset:+ 2
				Next
			Next
		Next
		
	End Method
	
	Method _readMetaData(fileIn:TStream, map:TileMap)
		
		If fileIn.Eof() Then Return
		
		Local metaCount:Short = filein.ReadShort()
		
		For Local i:Short = 1 To metaCount
			Local fieldName:String = fileIn.ReadString(fileIn.ReadShort())
			Local fieldValue:String = fileIn.ReadString(fileIn.ReadInt())
			map.SetMeta(fieldName, fieldValue)
		Next
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Internal save methods
	' ------------------------------------------------------------
	
	Method _writeLayers(fileOut:TStream, map:TileMap)
	
		Local xPos:Short
		Local yPos:Short
		
		For Local layer:Short = 1 To map._layerCount
			
			' write each layer
			Local offset:Int = map._layerOffset * (layer - 1)
			
			For yPos = 1 To map.GetHeight() 
				
				For xPos = 1 To map.GetWidth() 
					fileOut.WriteShort(map._mapData.PeekShort(offset))
					offset:+ 2
				Next
			
			Next

		Next
		
	End Method
	
	' [todo] - Don't use private fields here!
	Method _writeMetaData(fileOut:TStream, map:TileMap)
		
		fileOut.WriteShort(map.CountMetaFields())
		
		For Local Key:String = EachIn map._metaData.Keys()
			
			' Key
			fileOut.WriteShort(Key.Length)
			fileOut.WriteString(Key)
			
			' Value
			fileOut.WriteInt(String(map._metaData.ValueForKey(Key)).Length)
			fileOut.WriteString(String(map._metaData.ValueForKey(Key)))
			
		Next
	
	End Method
End Type
