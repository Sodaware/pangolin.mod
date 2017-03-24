' ------------------------------------------------------------------------------
' -- renderers/tilemap_request.bmx
' -- 
' -- RenderRequest for drawing a tilemap layer.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

import pangolin.TileMap
Import pangolin.gfx

Import "tile_animation_handler.bmx"

Type TileMapRequest Extends AbstractSpriteRequest
	
	Field _tileImage:TImage	'''< Image to render
	Field _tileset:TileSet
	Field _map:Tilemap
	
	' -- Used for rendering bounds
	Field _screenX:Int = 0
	Field _screenY:Int = 0
	Field _screenWidth:Int 
	Field _screenHeight:Int
	
	' -- Animation
	Field _frameTime:Float
	Field _animations:TList
	Field _animationLookups:TMap
	
	' -- Internal stuff
	Field _widthInTiles:Int
	Field _heightInTiles:Int
	Field _xScale:Float
	Field _yScale:Float
	Field _layer:Int
	Field _tilesetFrameCount:int
	
	Field _cachedCamera:AbstractRenderCamera
	
	' Update the animation frames
	Method update(delta:Float)
		
		' Do nothing if no animated tiles in this tileset
		If False = Self.hasAnimatedTiles() Then Return

		' Update each tileanimator
		For Local animation:TileAnimationHandler = EachIn Self._animations
			animation.update(delta)
		Next
		
	End Method
	
	Method render(tweening:Double, camera:AbstractRenderCamera, isFixed:Int = False)
		
		' Update the camera cache
		If Self._cachedCamera <> camera Then
			Self._cachedCamera = camera
			Self.recalculateOffsets()
		End If

		' Initiaze
		Self.setRenderState()
	
		If GetBlend() <> ALPHABLEND Then SetBlend ALPHABLEND 
		
		' [todo] - Cache this
		' -- Get the scaled tile dimensions
		Local scaledWidth:Float 	= Self._tileset.getTileWidth()
		Local scaledHeight:Float 	= Self._tileset.getTileHeight()
		
		' Gets the pixel offset
		Local xOffset:Int = (camera.getX() Mod scaledWidth)
		Local yOffset:Int = (camera.getY() Mod scaledHeight)
		
		' Render top to bottom
		Local mapXStart:Int =  (camera.getX() / scaledWidth)
		Local mapY:Int = (camera.getY() / scaledHeight)
		Local mapX:Int  = mapXStart
		Local tileY:Int = 0
		Local tileX:Int = 0
		Local previousAlpha:Float = brl.max2d.GetAlpha()
		
		' Loop variables
		Local tileId:Short
		Local currentTile:Tile
		Local currentAnimatedTile:AnimatedTile
		
		For Local yPos:Int = 0 To Self._heightInTiles
		
			tileX = 0
			mapX = mapXStart
			
			For Local xPos:Int = 0 To Self._widthInTiles
				
				tileId = Self._map.GetTile(Self._layer, mapX, mapY) - 1	
				If tileId < 0 Or tileId > self._tilesetFrameCount Then 
					tileId = 0
				endif
				
				' Only render if there's a valid tile
				If tileId Then 
				
					If Self._tileset.tileIsAnimated(tileId) Then
					
						' Get the animation name from the tile
						' TODO: Optimize this
						Local animationData:Tile = Tile(Self._tileset.getTileInfo(tileId))
						
						' Get the handler
						Local handler:TileAnimationHandler = TileAnimationHandler(Self._animationLookups.ValueForKey(animationData.getMeta("animation_name")))
						
						' TODO: Check something got picked up first
						
						currentTile = Self._tileset.getTileInfo(handler._currentFrame)
						
						' Get the handler for this tile
						If currentTile <> Null And previousAlpha <> currentTile.Alpha Then
							brl.max2d.SetAlpha currentTile.Alpha
							previousAlpha = currentTile.Alpha
						EndIf
					
						DrawImage Self._tileImage, tileX - xOffset, tileY - yOffset, currentTile.id
						
					
					Else
				
						currentTile = Self._tileset.GetTileInfo(tileId)			
						If currentTile <> Null And previousAlpha <> currentTile.Alpha Then
							brl.max2d.SetAlpha currentTile.Alpha
							previousAlpha = currentTile.Alpha
						EndIf
					
						DrawImage Self._tileImage, tileX - xOffset, tileY - yOffset, tileId
						
					EndIf
					
				EndIf
				
				tileX:+ scaledWidth
				mapX:+ 1
				
			Next
			
			tileY:+ scaledHeight
			mapY:+ 1
		Next
		
		brl.max2d.SetAlpha(previousAlpha)
	
	End Method
	
	
	' ------------------------------------------------------------
	' -- Internal Cache
	' ------------------------------------------------------------
	
	Method recalculateOffsets()
		
		' Calculate width in tileset
		Self._widthInTiles  = 2 + (Self._cachedCamera.getWidth() / Self._tileset.getTileWidth())
		Self._HeightInTiles = 2 + (Self._cachedCamera.getHeight() / Self._tileset.getTileHeight())		
		
	End Method
	
	Method hasAnimatedTiles:Byte()
		Return Self._tileset.countAnimatedTiles() > 0
	End Method
	
	
	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------
	
	Function Create:TilemapRequest(map:Tilemap, tileset:Tileset, tilesetImage:TImage, layer:Int)
		Local this:TilemapRequest = New TilemapRequest
		
		this._layer	= layer
		
		this._tileImage = tilesetImage
		this._tileset   = tileset
		this._map       = map
	
		' Scale 

		' Update internal cache
		this._tilesetFrameCount = tilesetImage.frames.length
		
		' Update animations
		this._animations = New TList
		this._animationLookups = New TMap
		
		If this.hasAnimatedTiles() Then
			For Local t:AnimatedTile = EachIn tileset._animatedTileLookup
				Local handler:TileAnimationHandler = New TileAnimationHandler
				
				handler._frames = New Int[t.m_TileList.Count()]
				For Local i:Int = 0 To handler._frames.length - 1
					handler._frames[i] = Int(t.m_TileList.ValueAtIndex(i).ToString())
				Next
				
				handler._frameTimers = New Int[t.m_TimerList.Count()]
				For Local i:Int = 0 To handler._frameTimers.length - 1
					handler._frameTimers[i] = Int(t.m_TimerList.ValueAtIndex(i).ToString())
				Next
				
				handler.play()
				this._animations.AddLast(handler)
				this._animationLookups.Insert(t.getName(), handler)
			Next
		End If
		
		
		Return this
	End Function
	
End Type
