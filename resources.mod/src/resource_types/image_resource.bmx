' ------------------------------------------------------------------------------
' -- src/resource_types/image_resource.bmx
' --
' -- Resource type to wrap Blitz images. Images can either be a single image
' -- or an imagestrip.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------



SuperStrict

Import brl.max2d

Import "../base_resource.bmx"


Type ImageResource Extends BaseResource .. 
	{ resource_type = "image, imagestrip" }
	
	Field _image:TImage					'''< Image handle for this resource
	Field _xOffset:Float
	Field _yOffset:Float
	
	
	' ------------------------------------------------------------
	' -- Public API
	' ------------------------------------------------------------
	
	''' <summary>Get internal handle.</summary>
	Method _get:TImage()
		Return Self._image
	End Method
	
	''' <summary>Load the resource.</summary>
	Method _load()
		
		Select Self.getDefinition().getType()
			
			Case "image"
				Self._image = LoadImage(Self.getDefinition().getFileName())
			
			Case "imagestrip"
				
				Self._image = LoadAnimImage(..
					Self.getDefinition().getFileName(), ..
					Int(self.getDefinition().getField("width")), ..
					Int(self.getDefinition().getField("height")), ..
					Int(self.getDefinition().getField("offset")), ..
					Int(self.getDefinition().getField("frames")) ..
				)
				
				If Self._image = Null Then
					DebugLog "Failed to load imagestrip ~q" + Self.getDefinition().getFullName() + "~q"
				End If
				
		End Select
		
		If Self._xOffset Or Self._yOffset Then
			SetImageHandle(Self._image, Self._xOffset, Self._yOffset)
		End If
		
		
	End Method
	
	''' <summary>Free the resource.</summary>
	Method _free()
		Self._image = Null
	End Method
			
	
	' ------------------------------------------------------------
	' -- Loading Definitions
	' ------------------------------------------------------------
	
	Method _loadDefinition()
		Self._xOffset = Float(Self.getDefinition().getField("x_handle", 0))
		Self._yOffset = Float(Self.getDefinition().getField("y_handle", 0))
	End Method
	
End Type
