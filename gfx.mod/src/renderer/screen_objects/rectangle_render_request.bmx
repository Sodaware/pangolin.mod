' ------------------------------------------------------------------------------
' -- src/renderer/screen_objects/rectangle_render_request.bmx
' -- 
' -- Renderable rectangle.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.retro
Import brl.max2d

Import "../../../pangolin_gfx.bmx"
Import "../abstract_sprite_request.bmx"


Type RectangleRenderRequest Extends AbstractSpriteRequest
	
	' Border
	Const BORDER_TOP:Byte 		= 1
	Const BORDER_RIGHT:Byte 	= 2
	Const BORDER_BOTTOM:Byte 	= 4
	Const BORDER_LEFT:Byte		= 8

	Field _width:Float
	Field _height: Float
	
	Field _borderColor:Int
	Field _borderThickness:Byte = 0
	Field _borderAlpha:Float = 1
	Field _borderVisibility:Byte = 15
	
	Field _backgroundAlpha:Float = 1
	Field _backgroundColor:Int
	
	Field _showBorder:Byte = True
	Field _showBackground:Byte = True
	Field _roundedBorder:Byte = False
	
	
	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------
	
	Method hide()
		Super.hide()
		Self.hideBorder()
		Self.hideBackground()
	End Method
	
	Method show()
		Super.show()
		Self.showBorder()
		Self.showBackground()
	End Method
	
	Method hideBorder:RectangleRenderRequest()
		Self._showBorder = False
		Return Self
	End Method

	Method showBorder:RectangleRenderRequest()
		Self._showBorder = True
		Return Self
	End Method

	Method setBorderThickness:RectangleRenderRequest(thickness:Byte)
		Self._borderThickness = thickness
		Return Self
	End Method

	Method setBorderVisibility:RectangleRenderRequest(borderVisibility:Byte = 0)
		Self._borderVisibility = borderVisibility
		Return Self
	End Method
	
	Method hideBackground:RectangleRenderRequest()
		Self._showBackground = False
		Return Self
	End Method

	Method showBackground:RectangleRenderRequest()
		Self._showBackground = True
		Return Self
	End Method
	
	Method setDimensions:RectangleRenderRequest(w:Float, h:Float)
		Self._width  = w
		Self._height = h
		Return Self
	End Method
	
	Method setBorderColor:RectangleRenderRequest(r:Byte, g:Byte, b:Byte)
		Self._borderColor = PangolinGfx.rgbToInt(r, g, b)
		Return Self
	End Method
	
	Method setBackgroundColor:RectangleRenderRequest(r:Byte, g:Byte, b:Byte)
		Self._backgroundColor = PangolinGfx.rgbToInt(r, g, b)
		Return Self
	End Method
	
	Method setBorderAlpha:RectangleRenderRequest(alpha:Float)
		Self._borderAlpha = alpha
		Return Self
	End Method

	Method setBackgroundAlpha:RectangleRenderRequest(alpha:Float)
		Self._backgroundAlpha = alpha
		Return Self
	End Method
	
	Method setBorderRounding:RectangleRenderRequest(enabled:Byte = False)
		Self._roundedBorder = enabled
		Return Self
	End Method
	
	
	' ------------------------------------------------------------
	' -- Rendering
	' ------------------------------------------------------------
	
	Method render(tween:Double, camera:AbstractRenderCamera, isFixed:Int = False)
		
		' Calculate new position
		Self._interpolate(1)
		
		' Set up appearance
		Self.setRenderState()
		
		' Render the background
		If Self._showBackground Then Self.renderBackground(camera, isFixed)
		If Self._ShowBorder Then Self.renderBorder(camera, isFixed)
		
		
	End Method
	
	Method renderBackground(camera:AbstractRenderCamera = null, isFixed:Int = False)

		Local xPos:Float = Self._tweenedPosition._xPos
		Local yPos:Float = Self._tweenedPosition._yPos
		Local width:Int  = Self._width
		Local height:Int = Self._height
		
		' Obey camera if needed
		If camera And False = isfixed And False = Self.isIgnoringCamera() Then
			xPos :- camera.getX()
			yPos :- camera.getY()
		EndIf	
		
		If Self._showBorder Then
			xPos:+ Self._borderThickness
			yPos:+ Self._borderThickness
			width = width - (Self._borderThickness * 2)
			height = height - (Self._borderThickness * 2)
		End If
		
		brl.max2d.SetBlend(ALPHABLEND)
		brl.max2d.SetAlpha(Self._backgroundAlpha)
		
		PangolinGfx.SetColorInt(Self._backgroundColor)
		DrawRect(xPos, yPos, width, height)
		
		' Reset rendering
		brl.max2d.SetBlend(MASKBLEND)
		brl.max2d.SetAlpha(1)
		
	End Method
	
	Method renderBorder(camera:AbstractRenderCamera = null, isFixed:Int = False)
	
		Local xPos:Float = Self._tweenedPosition._xPos
		Local yPos:Float = Self._tweenedPosition._yPos
		Local width:Int  = Self._width
		Local height:Int = Self._height
		
		' Obey camera if needed
		If camera And False = isfixed And False = Self.isIgnoringCamera() Then
			xPos :- camera.getX()
			yPos :- camera.getY()
		EndIf	
	
		brl.max2d.SetBlend(ALPHABLEND)
		brl.max2d.SetAlpha(Self._borderAlpha)
	
		PangolinGfx.SetColorInt(Self._borderColor)
		
		Local borderOffset:Int = 0
		If Self._roundedBorder Then borderOffset = Self._borderThickness
		
		' Draw the top line
		If (Self._borderVisibility & BORDER_TOP) Then
			DrawRect(xPos + borderOffset, yPos, Self._width - (borderOffset + borderOffset), Self._borderThickness)
		EndIf

		' Draw the bottom line
		If (Self._borderVisibility & BORDER_BOTTOM) Then 
			DrawRect(xPos + borderOffset, yPos + Self._height - Self._borderThickness, Self._width - (borderOffset + borderOffset), Self._borderThickness)
		EndIf
		
		' Draw the left
		If (Self._borderVisibility & BORDER_LEFT) Then
			DrawRect(xPos, yPos + Self._borderThickness, Self._borderThickness, Self._height - (Self._borderThickness * 2))
		EndIf
		
		' Draw the left
		If (Self._borderVisibility & BORDER_RIGHT) Then 
			DrawRect(xPos + Self._width - Self._borderThickness, yPos + Self._borderThickness, Self._borderThickness, Self._height - (Self._borderThickness * 2))
		EndIf

		SetColor 255, 255, 255
		
		brl.max2d.SetBlend(MASKBLEND)
		brl.max2d.SetAlpha(1)
		
	End Method
	
	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------
	
	Function Create:RectangleRenderRequest(xPos:Int, yPos:Int, width:Int, height:Int)
		Local this:RectangleRenderRequest = New RectangleRenderRequest
		this.setPosition(xPos, yPos)
		this.setDimensions(width, height)
		this.hideBorder()
		Return this
	End Function
	
End Type