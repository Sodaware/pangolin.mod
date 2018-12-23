' ------------------------------------------------------------------------------
' -- src/resource_types/tileset_resource.bmx
' -- 
' -- Resource type to wrap Pangolin tileset.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.TileMap
Import "../base_resource.bmx"


Type TileSetResource Extends BaseResource ..
	{ resource_type = "tileset" }
	

	Field _tileset:TileSet
	
	' ------------------------------------------------------------
	' -- Public API
	' ------------------------------------------------------------
	
	''' <summary>Get internal handle.</summary>
	Method _get:TileSet()
		Return Self._tileset
	End Method
	
	''' <summary>Load the resource.</summary>
	Method _load()
		Self._tileset = TileMapLoader.LoadTileSet(Self.getFileName())
		if not(self._tileset) Then
			debuglog "Could not load tileset from: " + Self.getFileName()
			Return
		endif
		Self._tileset._updateInternals()
	End Method
	
	''' <summary>Free the resource.</summary>
	Method _free()
		
	End Method
         
	
	' ------------------------------------------------------------
	' -- Loading Definitions
	' ------------------------------------------------------------
	
	Method _loadDefinition()
	 	
	End Method
	
End Type
