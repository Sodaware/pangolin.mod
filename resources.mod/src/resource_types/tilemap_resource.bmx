' ------------------------------------------------------------------------------
' -- src/resource_types/tilemap_resource.bmx
' -- 
' -- Resource type to wrap Pangolin tilemap.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.TileMap
Import "../base_resource.bmx"

Type TileMapResource Extends BaseResource ..
	{ resource_type = "tilemap" }

	Field _tilemap:TileMap
	
	' ------------------------------------------------------------
	' -- Public API
	' ------------------------------------------------------------
	
	''' <summary>Get internal handle.</summary>
	Method _get:TileMap()
		Return Self._tilemap
	End Method
	
	''' <summary>Load the resource.</summary>
	Method _load()
		Self._tilemap = TileMapLoader.LoadTileMap(Self.getFileName())
	End Method
	
	''' <summary>Free the resource.</summary>
	Method _free()
		Self._tilemap = Null
	End Method
         
	
	' ------------------------------------------------------------
	' -- Loading Definitions
	' ------------------------------------------------------------
	
	Method _loadDefinition()
	 	
	End Method
	
End Type
