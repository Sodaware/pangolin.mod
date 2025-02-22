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

''' <summary>
''' Renderable progress bar.
'''
''' The progress bar consists of a background rectangle, an optional border, and a
''' filled bar that represents the current progress. The bar can be customized with
''' different colors and alpha values.
'''
''' The progress can be set either as a direct percentage (between 0 and 1) or by
''' setting a maximum value and current value.
''' </summary>
Type ProgressBarRenderRequest Extends RectangleRenderRequest

	Field _barAlpha:Float = 1
	Field _barColor:Int
	Field _percentage:Float
	Field _padding:Int = 0

	Field _maxValue:Float
	Field _currentValue:Float

	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------

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

	''' <summary>Set the progress bar completion percentage.</summary>
	''' <param name="percentage">The percentage of the bar to fill, between 0 and 1.</param>
	''' <returns>The ProgressBarRenderRequest instance.</returns>
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

	' ------------------------------------------------------------
	' -- Visibility
	' ------------------------------------------------------------

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

	' ------------------------------------------------------------
	' -- Rendering
	' ------------------------------------------------------------

	Method render(tween:Double, camera:AbstractRenderCamera, isFixed:Byte = False)
		Self._interpolate(tween)

		' Draw the frame and background.
		Super.render(tween, camera, isFixed)

		' Draw the inner bar.
		Self.renderBar(camera, isFixed)
	End Method

	' Render the bar contents. Frane and background is rendered elsewhere.
	Method renderBar(camera:AbstractRenderCamera, isFixed:Int = False)
		' Don't draw if invisible or the bar is empty.
		If Self.isHidden() or Self._percentage <= 0 Then Return

		' Calculate positions and dimensions.
		Local xPos:Float = Self._tweenedPosition._xPos
		Local yPos:Float = Self._tweenedPosition._yPos
		Local width:Int  = Self._width
		Local height:Int = Self._height

		' Adjust position if camera is active and being used.
		If camera And False = isfixed And False = Self.isIgnoringCamera() Then
			xPos :- camera.getX()
			yPos :- camera.getY()
		EndIf

		' Apply border adjustments.
		If Self._showBorder Then
			xPos:+ Self._borderThickness
			yPos:+ Self._borderThickness
			width :- (Self._borderThickness * 2)
			height :- (Self._borderThickness * 2)
		End If

		' Apply padding adjustments.
		If Self._padding <> 0 Then
			xPos:+ Self._padding
			yPos:+ Self._padding
			width = width - (Self._padding * 2)
			height = height - (Self._padding * 2)
		End If
		' Set render state.
		brl.max2d.SetBlend(ALPHABLEND)
		brl.max2d.SetAlpha(Self._barAlpha)
		PangolinGfx.SetColorInt(Self._barColor)

		' Draw the progress bar.
		DrawRect(xPos, yPos, width * Self._percentage, height)

		' Reset render state.
		brl.max2d.SetBlend(MASKBLEND)
		brl.max2d.SetAlpha(1)
	End Method

	' ------------------------------------------------------------
	' -- Internal Helpers
	' ------------------------------------------------------------

	''' <summary>
	''' Recalculate the internal percentage.
	'''
	''' This must be called after setting either `currentValue` or `maxValue`.
	''' </summary>
	Method updatePercentage()
		Self._percentage = (Self._currentValue / Self._maxValue)
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
