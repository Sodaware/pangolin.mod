' ------------------------------------------------------------------------------
' -- src/renderer/screen_objects/progress_bar_render_request.bmx
' -- 
' -- Renderable progress bar.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../../../pangolin_gfx.bmx"
Import "../abstract_sprite_request.bmx"
Import "rectangle_render_request.bmx"

Type ProgressBarRenderRequest Extends RectangleRenderRequest
	
	Field _barAlpha:Float = 1
	Field _barColor:Int
	Field _percentage:Float
	Field _padding:Int = 0
	
	Field _maxValue:Float
	Field _currentValue:Float
	
	Method hide()
		Super.hide()
		Self.hideBackground()
		Self.hideBorder()
	End Method
	
	Method show()
		Super.show()
		Self.showBackground()
		Self.showBorder()
	End Method
	
	Method setPadding:ProgressBarRenderRequest(padding:Int)
		Self._padding = padding

		Return Self
	End Method
	
	Method setBarColor:ProgressBarRenderRequest(r:Byte, g:Byte, b:Byte)
		Self._barColor = PangolinGfx.RgbToInt(r, g, b)

		Return Self
	End Method
	
	Method setBarAlpha:ProgressBarRenderRequest(alpha:Float)
		Self._barAlpha = alpha

		Return Self
	End Method
	
	Method setPercentage:ProgressBarRenderRequest(percentage:Float)
		Self._percentage = percentage

		Return Self
	End Method
	
	Method setMaxValue:ProgressBarRenderRequest(value:Float)
		Self._maxValue = value
		Self.updatePercentage()

		Return Self
	End Method
	
	Method setCurrentValue:ProgressBarRenderRequest(value:Float)
		Self._currentValue = value
		Self.updatePercentage()

		Return Self
	End Method
	
	Method updatePercentage()
		Self._percentage = (Self._currentValue / Self._maxValue)
	End Method
	
	' ------------------------------------------------------------
	' -- Rendering
	' ------------------------------------------------------------
	
	Method render(tween:Double, camera:AbstractRenderCamera, isFixed:Byte = False)
		
		Self._interpolate(tween)
		
		' Draw the main bar
		Super.render(tween, camera, isFixed)
		
		' Draw the foreground
		Self.renderBar(camera, isFixed)
		
	End Method
	
	Method renderBar(camera:AbstractRenderCamera, isFixed:Int = False)

		' Only draw if visible
		If Not Self.isVisible() Then Return
		
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
		
		If Self._padding <> 0 Then
			xPos:+ Self._padding
			yPos:+ Self._padding
			width = width - (Self._padding * 2)
			height = height - (Self._padding * 2)
		End If
		
		brl.max2d.SetBlend(ALPHABLEND)
		brl.max2d.SetAlpha(Self._barAlpha)
		
		PangolinGfx.SetColorInt(Self._barColor)
		DrawRect(xPos, yPos, width * Self._percentage, height)

		' Reset rendering
		brl.max2d.SetBlend(MASKBLEND)
		brl.max2d.SetAlpha(1)
		
	End Method
	
		
	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------
	
	Function Create:ProgressBarRenderRequest(xPos:Int, yPos:Int, width:Int, height:Int)
		Local this:ProgressBarRenderRequest = New ProgressBarRenderRequest

		this.setPosition(xPos, yPos)
		this.setDimensions(width, height)
		this.hideBorder()

		Return this
	End Function
	
End Type
