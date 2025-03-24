' ------------------------------------------------------------------------------
' -- src/xml_tile_set_serializer.bmx
' --
' -- Adds support for loading pangolin tilsets using the XML format.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2019 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.tilemap
Import prime.maxml

Type XmlTileSetSerializer Extends BaseTileSetSerializer

	Method load:TileSet(fileIn:TStream)

		' Load the xml document.
		Local document:xmlDocument = xmlDocument.Create(fileIn)
		Local rootNode:xmlNode     = document.Root()

		' Check it was loaded correctly.
		If rootNode = Null Then Return Null

		' Create the tileset to be loaded.
		Local set:TileSet = New TileSet

		' Load meta information.
		Self._loadTilesetMeta(rootNode, set)

		' Load tiles and animated tiles.
		Self._loadTiles(rootNode, set)
		Self._loadAnimatedTiles(rootNode, set)

		' Refresh internals and return.
		set._updateInternals()

		Return set

	End Method

	Method save(fileOut:TStream, set:TileSet)

		' Create the XML doc.
		Local document:xmlDocument = New xmlDocument
		Local rootNode:xmlNode     = document.Root()

		' Setup root node.
		rootNode.Name = "Tileset"

		' Add meta data.
		Local metaNode:xmlNode = rootNode.AddNode("Info")
		For Local key:String = EachIn set._metaData.keys()
			Local value:xmlNode = metaNode.AddNode(key)
			value.value = set.getMeta(key)
		Next

		' Add tiles.
		Local tilesNode:xmlNode = rootNode.AddNode("Tiles")
		For Local t:Tile = EachIn set._tiles
			Local tileNode:xmlNode = tilesNode.AddNode("Tile")

			' Set the identifier.
			Self._setAttribute(tileNode, "id", t.id)

			' Set shortcut if all the same.
			If t.allCollidable() Then
				Self._setAttribute(tileNode, "collision", True)
			ElseIf Not t.notAllCollidable() Then
				Self._setAttribute(tileNode, "cleft", t.CollideLeft)
				Self._setAttribute(tileNode, "cup", t.CollideUp)
				Self._setAttribute(tileNode, "cdown", t.CollideDown)
				Self._setAttribute(tileNode, "cright", t.CollideRight)
			EndIf

			If t.alpha <> 1 Then
				Self._setAttribute(tileNode, "alpha", t.alpha)
			EndIf

			' Write meta.
			If t._meta <> Null Then
				For Local key:String = EachIn t._meta.Keys()
					Self._setAttribute(tileNode, key, String(t.getMeta(key)))
				Next
			EndIf
		Next

		' Save animations.
		If set.countAnimatedTiles() > 0 Then
			Local animNode:xmlNode = rootNode.AddNode("AnimatedTiles")
			For Local a:AnimatedTile = EachIn set._animatedTiles
				Local animatedTileNode:xmlNode = animNode.AddNode("AnimatedTile")
				Self._setAttribute(animatedTileNode, "name", String(a.getMeta("name")))

				If a.isLooped Then
					Self._setAttribute(animatedTileNode, "loop", "true")
				Else
					Self._setAttribute(animatedTileNode, "loop", "false")
				EndIf

				' Add frames.
				For Local i:Int = 0 To a.countFrames() - 1
					Local frameNode:xmlNode = animatedTileNode.AddNode("Frame")
					Self._setAttribute(frameNode, "tile", a.getFrame(i))
					Self._setAttribute(frameNode, "time", a.getTimer(i))
				Next
			Next
		EndIf

		' Write to stream.
		document.Save(fileOut)
	'	fileOut.WriteString(tilesetDoc.
	End Method

	Method isMetaField:Byte(name:String)
		If name = "collision" Then Return False
		If name = "cleft" Then Return False
		If name = "cright" Then Return False
		If name = "cup" Then Return False
		If name = "cdown" Then Return False
		If name = "alpha" Then Return False
		If name = "id" Then Return False
		Return True
	End Method

	Method _loadTilesetMeta(root:xmlNode, set:TileSet)
		' Get the "info" node.
		Local infoNode:xmlNode = root.FindChild("Info")
		If infoNode = Null Then Return

		' Load each keyword.
		For Local node:xmlNode = EachIn infoNode.ChildList
			set.setMeta(node.Name, node.Value)
		Next

		' Set width / height.
		If set.getMeta("width")  <> Null Then set._tileWidth = Int(set.getMeta("width"))
		If set.getMeta("height") <> Null Then set._tileheight = Int(set.getMeta("height"))

	End Method

	Method _loadTiles(root:xmlNode, set:TileSet)
		Local tiles:xmlNode = root.FindChild("Tiles")
		If tiles = Null Then Return

		' Add each individual tile.
		For Local tileNode:xmlNode = EachIn tiles.ChildList

			' Get default collision value.
			Local defaultCollide:Byte = Self._getIntAttribute(tileNode, "collision", 0)

			Local t:Tile = Tile.Create(..
				Self._getByteAttribute(tileNode, "cup", defaultCollide), ..
				Self._getByteAttribute(tileNode, "cright", defaultCollide), ..
				Self._getByteAttribute(tileNode, "cdown", defaultCollide), ..
				Self._getByteAttribute(tileNode, "cleft", defaultCollide) ..
			)

			t.id = Int(tileNode.attributeValue("id"))
			If tileNode.HasAttribute("alpha") Then t.Alpha = Float(tileNode.attributeValue("alpha"))

			' Load meta
			For Local item:xmlAttribute = EachIn tileNode.AttributeList
				If Self.isMetaField(item.Name) Then
					t.setMeta(item.Name, item.Value)
				End If
			Next

			If t Then set.AddTile(t)
		Next
	End Method

	Method _loadAnimatedTiles(root:xmlNode, set:TileSet)
		Local tiles:xmlNode = root.FindChild("AnimatedTiles")
		If tiles = Null Then Return

		' Add each individual tile.
		For Local tileNode:xmlNode = EachIn tiles.ChildList
			Local animTile:AnimatedTile = New AnimatedTile

			animTile.setMeta("name", tileNode.attributeValue("name"))
			animTile.isLooped = ("true" = tileNode.attributeValue("loop"))

			' Add each frame.
			For Local frameNode:xmlNode = EachIn tileNode.ChildList
				If frameNode.Name <> "Frame" Then Continue

				animTile.addFrame( ..
					Self._getIntAttribute(frameNode, "tile"), ..
					Self._getIntAttribute(frameNode, "time") ..
				)
			Next

			' Add to the tileset.
			set.addAnimatedTile(animTile)
		Next
	End Method

	Method _setAttribute:xmlAttribute(node:xmlNode, name:String, value:String)
		Local att:xmlAttribute = node.Attribute(name)
		att.value = value

		Return att
	End Method

	Method _getIntAttribute:Int(node:xmlNode, name:String, defaultValue:Int = 0)
		Local value:String = node.attributeValue(name)

		If value <> "" Then Return Int(value)

		Return defaultValue
	End Method

	Method _getByteAttribute:Byte(node:xmlNode, name:String, defaultValue:Byte = 0)
		Local value:String = node.attributeValue(name)

		If value <> "" Then Return Byte(value)

		Return defaultValue
	End Method


End Type
