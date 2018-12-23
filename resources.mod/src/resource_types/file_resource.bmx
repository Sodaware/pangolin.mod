' ------------------------------------------------------------------------------
' -- src/resource_types/file_resource.bmx
' --
' -- Resource type for a single file. Returns a stream to the file when 
' -- accessed.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.standardio
Import "../base_resource.bmx"


Type FileResource Extends BaseResource ..
	{ resource_type = "file" }
	
	' ------------------------------------------------------------
	' -- Public API
	' ------------------------------------------------------------
	
	''' <summary>Get internal handle.</summary>
	Method _get:Object()
		Return OpenStream(Self.getFileName())
	End Method
	
	''' <summary>Load the resource.</summary>
	Method _load()
		
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
