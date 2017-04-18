' ------------------------------------------------------------------------------
' -- src/serializers/binary/binary_tileset_serializer.bmx
' --
' -- Binary serializer for tilesets. Binary tilesets are fast to load but 
' -- aren't stored in human-friendly format.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../base_tileset_serializer.bmx"

Type BinaryTileSetSerializer Extends BaseTileSetSerializer
	
	Const HEADER:String = "PT"
	
	
	' ------------------------------------------------------------
	' -- Load & Save
	' ------------------------------------------------------------

	Method Load:TileSet(fileIn:TStream)
		
		' Check the header
		If fileIn.ReadString(HEADER.Length) <> HEADER Then Return Null
	
		' Read the number of tiles
		Local set:TileSet	= TileSet.Create()
		
		Local tileCount:Int = fileIn.ReadShort()
		Local animCount:Int = fileIn.ReadShort()
		
		' Read layers & meta data
		Self._readTiles(fileIn, set, tileCount)
		Self._readAnimatedTiles(fileIn, set, animCount)
		Self._readMetaData(fileIn, set)
		
		If set.getMeta("width") <> Null Then set._tileWidth = Int(set.getMeta("width"))
		If set.getMeta("height") <> Null Then set._tileheight = Int(set.getMeta("height"))
		
		Return set
	
	End Method
	
	Method save(fileOut:TStream, set:TileSet)
		
		' Write header
		fileOut.WriteString(HEADER)
		
		' Write tile counts
		fileOut.WriteShort(set.countTiles())
		fileOut.WriteShort(set.countAnimatedTiles())
		
		' Write regular tiles
		Self._writeTiles(fileOut, set)
		
		' Write animated tiles
		Self._writeAnimatedTiles(fileOut, set)
		
		' Write meta data
		Self._writeMetaData(fileOut, set)
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Internal load methods
	' ------------------------------------------------------------
	
	Method _readTiles(fileIn:TStream, set:Tileset, tileCount:Int)
		
		For Local offset:Int = 0 To tileCount - 1
			Local t:Tile = Self._readTile(fileIn)
			If t <> Null Then set.AddTile(t)
		Next
		
	End Method
	
	Method _readAnimatedTiles(fileIn:TStream, set:TileSet, tileCount:Int)

		For Local offset:Int = 0 To tileCount - 1
			Local t:AnimatedTile = Self._readAnimatedTile(fileIn)
			If t <> Null Then set.addAnimatedTile(t)
		Next
		
	End Method
	
	Method _readMetaData(fileIn:TStream, set:TileSet)
		
		If fileIn.Eof() Then Return
		
		Local metaCount:Short = filein.ReadShort()
		
		For Local i:Short = 1 To metaCount
			Local fieldName:String = fileIn.ReadString(fileIn.ReadShort())
			Local fieldValue:String = fileIn.ReadString(fileIn.ReadInt())
			set.SetMeta(fieldName, fieldValue)
		Next
		
	End Method
	
	Method _readTile:Tile(fileIn:TStream)
		
		' Check inputs
		If fileIn = Null Or fileIn.Eof() Then Return Null
	
		Local this:Tile = New Tile
	
		' Read collision data
		this.id           = fileIn.ReadInt()
		this.CollideUp    = fileIn.ReadByte()
		this.CollideRight = fileIn.ReadByte()
		this.CollideDown  = fileIn.ReadByte()
		this.CollideLeft  = fileIn.ReadByte()
		
		' Read alpha
		this.Alpha		  = Float(fileIn.ReadByte()) / 255.0
		
		' Read any meta fields for his tile
		Local metaCount:Int = filein.ReadShort()
		If metaCount > 0 Then
			For Local i:Int = 1 To metaCount
				Local fieldName:String  = fileIn.ReadString(fileIn.ReadShort())
				Local fieldValue:String = fileIn.ReadString(fileIn.ReadInt())
			
				this.setMeta(fieldName, fieldValue)
			Next
		End If
		
		Return this
		
	End Method
	
	Method _readAnimatedTile:AnimatedTile(fileIn:TStream)
		
		' Check inputs
		If fileIn = Null Or fileIn.Eof() Then Return Null
		
		Local this:AnimatedTile = New Animatedtile
		
		this.setMeta("name", Self.readStringWithLength(fileIn))
		this.isLooped = fileIn.ReadByte()
		
		' Read frame count
		Local frameCount:Short = fileIn.ReadShort()
		
		For Local i:Int = 0 To frameCount - 1
			this.addFrame(fileIn.ReadInt(), fileIn.ReadInt())
		Next
		
		Return this
		
	End Method
	
	' ------------------------------------------------------------
	' -- Internal save methods
	' ------------------------------------------------------------
	
	Method _writeTiles(fileOut:TStream, set:TileSet)
		
		For Local t:Tile = EachIn set._tiles
			Self._writeTile(fileOut, t)
		Next
		
	End Method
	
	Method _writeTile(fileOut:TStream, t:Tile)
		
		' Collision
		fileOut.WriteInt(t.id)
		fileOut.WriteByte(t.CollideUp)
		fileOut.WriteByte(t.CollideRight)
		fileOut.WriteByte(t.CollideDown)
		fileOut.WriteByte(t.CollideLeft)
		
		' Alpha
		fileOut.WriteByte(t.Alpha * 255.0)
		
		' Write any meta fields for his tile
		Local metaCount:Short = t.countMeta()
		fileOut.WriteShort(metaCount)
		
		If metaCount > 0 Then
			For Local key:String = EachIn t._meta.Keys()
				fileOut.WriteShort(key.Length)
				fileOut.WriteString(key)
				fileOut.WriteInt(t.getMeta(key).ToString().Length)
				fileOut.WriteString(t.getMeta(key).ToString())
			Next
		End If
		
	End Method

	Method _writeAnimatedTiles(fileOut:TStream, set:TileSet)
		
		For Local t:AnimatedTile = EachIn set._animatedTiles
			
			' Write name
			Self.writeStringWithLength(fileOut, String(t.getMeta("name")))
			
			' Write loop data
			fileOut.WriteByte(t.isLooped)
			
			' Write each frame
			fileOut.WriteShort(t.countFrames())
			
			For Local frameId:Int = 0 To t.countFrames() - 1
				fileOut.WriteInt(t.getFrame(frameId))
				fileOut.WriteInt(t.getTimer(frameId))
			Next
			
		Next
		
	End Method

		
	Method _writeMetaData(fileOut:TStream, set:TileSet)
		
		fileOut.WriteShort(set.CountMetaFields())
		
		For Local Key:String = EachIn set._metaData.Keys()
			
			' Key
			fileOut.WriteShort(Key.Length)
			fileOut.WriteString(Key)
			
			' Value
			fileOut.WriteInt(String(set._metaData.ValueForKey(Key)).Length)
			fileOut.WriteString(String(set._metaData.ValueForKey(Key)))
			
		Next
	
	End Method

	Method writeStringWithLength(fileOut:TStream, value:String)
		fileOut.WriteInt(value.Length)
		fileOut.WriteString(value)
	End Method

	Method readStringWithLength:String(fileIn:TStream)
		Local length:Int = fileIn.ReadInt()
		Return fileIn.ReadString(length)
	End Method
	
End Type
