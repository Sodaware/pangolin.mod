' ------------------------------------------------------------------------------
' -- src/serializers/tilemap_loader.bmx
' -- 
' -- Helper for loading tilemaps and tilesets.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------

SuperStrict

Import pangolin.core

Import "base_tilemap_serializer.bmx"
Import "base_tileset_serializer.bmx"


Type TileMapLoader

	' TODO: This is as ugly as sin. Find a better way :D
	Function GetTilesetSerializer:BaseTilesetSerializer(url:Object)
		
		' Attempt to read tileset stream
		Local fileIn:TStream = TileMapLoader._openFile(url)
		If Not(fileIn) Then Return Null
		
		Local startPosition:Int = fileIn.Pos()
		
		' Attempt to serialize tileset through various sub-types
		Local set:TileSet
		
		Local id:TTypeId = TTypeId.ForName("BaseTilesetSerializer")
		
		For Local loader:TTypeId = EachIn id.DerivedTypes()
			Local serializer:BaseTilesetSerializer = BaseTilesetSerializer(loader.NewObject())
			fileIn.Seek(startPosition)
			set = serializer.Load(fileIn)
			If set <> Null Then 
				fileIn.close()
				return serializer
			endif
		Next
		
		fileIn.close()
		return null
		
	End Function

	' ------------------------------------------------------------
	' -- Loading
	' ------------------------------------------------------------
	
	Function LoadTileMap:TileMap( url:Object )
		
		' Attempt to read map stream
		Local fileIn:TStream = TileMapLoader._openFile(url)
		If Not(fileIn) Then Return Null
		
		Local startPosition:Int = fileIn.Pos()

		' Attempt to serialize map through various sub-types
		Local map:TileMap
		
		Local id:TTypeId = TTypeId.ForName("BaseTileMapSerializer")
		For Local loader:TTypeId = EachIn id.DerivedTypes()
			
			Local serializer:BaseTileMapSerializer = BaseTileMapSerializer(loader.NewObject())
			
			fileIn.Seek(startPosition)
			
			map = serializer.Load(fileIn)
			
			If map <> Null Then Exit
			
		Next
		
		' Cleanup & return
		fileIn.Close()
		Return map

	End Function
	
	Function LoadTileSet:TileSet( url:Object )
		
		' Attempt to read tileset stream
		Local fileIn:TStream = TileMapLoader._openFile(url)
		If Not(fileIn) Then Return Null
		
		Local startPosition:Int = fileIn.Pos()
		
		' Attempt to serialize tileset through various sub-types
		Local set:TileSet
		
		Local id:TTypeId = TTypeId.ForName("BaseTileSetSerializer")
		
		For Local loader:TTypeId = EachIn id.DerivedTypes()
			Local serializer:BaseTileSetSerializer = BaseTileSetSerializer(loader.NewObject())
			fileIn.Seek(startPosition)
			set = serializer.Load(fileIn)
			If set <> Null Then Exit
		Next
		
		' Cleanup & return
		fileIn.Close()
		Return set
	
	End Function


	' ------------------------------------------------------------
	' -- Saving
	' ------------------------------------------------------------

	Function SaveTileMap:Int( url:Object, map:TileMap )
		rem
		' Attempt to read map stream
		Local fileIn:TStream = TileMapLoader._openFile(url)
		If Not(fileIn) Then Return Null
		
		Local startPosition:Int = fileIn.Pos()

		' Attempt to serialize map through various sub-types
	
		
		Local id:TTypeId = TTypeId.ForName("TileMapSerializer")
		For Local loader:TTypeId = EachIn id.DerivedTypes()
			
			Local serializer:TileMapSerializer = TileMapSerializer(loader.NewObject())
			
			fileIn.Seek(startPosition)
			
			map = serializer.Load(fileIn)
			
			If map <> Null Then Exit
			
		Next
		
		' Cleanup & return
		fileIn.Close()
		Return True
		end rem

	End Function
	
	Function SaveTileSet:Int(url:Object, set:TileSet , serializer:BaseTileSetSerializer)
		
		Local fileOut:TStream = WriteFile(url)
		If fileOut = Null Then Return -1
		
		' Save with the serializer
		serializer.Save(fileOut, set)
		
		fileOut.Close()
	
		Return True
		
	
	rem
	
		' Attempt to read tileset stream
		Local fileIn:TStream = TileMapLoader._openFile(url)
		If Not(fileIn) Then Return Null
		
		Local startPosition:Int = fileIn.Pos()
		
		' Attempt to serialize tileset through various sub-types
	
		Local id:TTypeId = TTypeId.ForName("TileSetSerializer")
		
		For Local loader:TTypeId = EachIn id.DerivedTypes()
			Local serializer:TileSetSerializer = TileSetSerializer(loader.NewObject())
			fileIn.Seek(startPosition)
			set = serializer.Load(fileIn)
			If set <> Null Then Exit
		Next
		
		' Cleanup & return
		fileIn.Close()
		Return set
		
		end rem
	
	End Function
	
	' ------------------------------------------------------------
	' -- Internal helpers
	' ------------------------------------------------------------

	rem
	Function _loadFile:Object(fileIn:TStream, startPosition:Int, serializerType:TTypeId)
		
		Local loadedObject:Object
		
		For Local loader:TTypeId = EachIn serializerType.DerivedTypes()
			Local serializer:ObjectSerializer = ObjectSerializer(loader.NewObject())
			fileIn.Seek(startPosition)
			loadedObject = serializer.Load(fileIn)
			If loadedObject <> Null Then Return loadedObject
		Next
		
		
	End Function
	end rem
		
	Function _openFile:TStream(url:Object)
		
		' Attempt to read map stream
		Local fileIn:TStream = ReadStream( url )
		If Not(fileIn) Then Return Null

		' Check position in stream is correct
		If fileIn.Pos() = -1
			fileIn.Close()
			Return Null
		EndIf
		
		Return fileIn
		
	End Function
	
	Function _writeFile:TStream(url:Object)
		
		' Attempt to read map stream
		Local fileOut:TStream = WriteStream( url )
		If Not(fileOut) Then Return Null

		' Check position in stream is correct
		If fileOut.Pos() = -1
			fileOut.Close()
			Return Null
		EndIf
		
		Return fileOut
		
	End Function
	
End Type
