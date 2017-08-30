' ------------------------------------------------------------------------------
' -- src/renderer/screen_objects/tile_image_sprite.bmx
' -- 
' -- A tiled sprite images.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.max2d

Import "../abstract_sprite_request.bmx"
Import "../../util/graphics_util.bmx"

' TODO: Can this extend ImageSprite instead?
Type TileImageRequest Extends AbstractSpriteRequest

	Field _frame:Int				'''< Current frame
	Field _image:TImage				'''< Image strip to display
	Field _width:Int
	Field _height:Int
	Field _xOff:Float
	Field _yOff:Float
	
	
	' ------------------------------------------------------------
	' -- Setting image / frame
	' ------------------------------------------------------------
	
	Method setImage(image:TImage, frame:Int = 0)
		Self._image = image
		Self._frame = frame
	End Method
	
	Method setFrame(frame:Int = 0)
		Self._frame = frame
	End Method
	
	Method setDimensions(width:Int, height:Int)
		Self._width		= width
		Self._height	= height
	End Method
	
	Method setOffset(xOff:Float, yOff:Float)
		Self._xOff = xOff
		Self._yOff = yOff
	End Method
	
	
	' ------------------------------------------------------------
	' -- Rendering
	' ------------------------------------------------------------
	
	Method render(tween:Double, camera:AbstractRenderCamera, isFixed:Byte = false)
		
		Self._interpolate(tween)
		Self.setRenderState()
		
		' Render
		If Self._image And Self.isVisible() Then
			Local x:Int, y:Int, w:Int, h:Int
			
			If Self._width And Self._height Then
				GetViewport(x, y, w, h)
				SetViewport(Self._tweenedPosition._xPos, Self._tweenedPosition._yPos, Self._width, Self._height)
			End If
			
			TileImageScaled(Self._image, Self._tweenedPosition._xPos + Self._xOff, Self._tweenedPosition._yPos + Self._yOff, Self._frame)
			
			If Self._width And Self._height Then
				SetViewport(x, y, w, h)
			EndIf
		End If
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------
	
	Function Create:TileImageRequest(image:TImage, xPos:Int = 0, yPos:Int = 0, width:Int = 0, height:Int = 0)
		Local this:TileImageRequest = New TileImageRequest
		this.setImage(image)
		this.setPosition(xPos, yPos)
		this.setDimensions(width, height)
		Return this
	End Function
	
End Type
