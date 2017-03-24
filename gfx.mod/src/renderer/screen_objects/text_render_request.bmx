' ------------------------------------------------------------------------------
' -- src/renderer/screen_objects/text_render_request.bmx
' -- 
' -- Renderable text.
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
Import "../../util/text_render_style.bmx"
Import "../abstract_sprite_request.bmx"


Type TextRenderRequest Extends AbstractSpriteRequest

	Const ALIGN_LEFT:Byte 	= 1
	Const ALIGN_CENTER:Byte	= 2
	Const ALIGN_RIGHT:Byte	= 3

	Field _text:String
	Field _wrap:Byte = False
	
	Field _font:TImageFont
	Field _width:Float
	Field _height: Float
	
	Field _fontColor:Int			= 0
	Field _shadowColor:Int			= -1
	Field _shadowAlpha:Float		= 0.5
	Field _shadowXDistance:Short	= 1
	Field _shadowYDistance:Short	= 1
	Field _alignment:Byte			= ALIGN_LEFT
	
	
	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------
	
	''' <summary>
	''' Set the text style using a TextRenderStyle object. This makes it easier
	''' to create multiple labels that all use a similar style.
	''' </summary>
	''' <param name="style">The render style to set.</param>
	Method setStyle:TextRenderRequest(style:TextRenderStyle)
		
		Self.setAlignment(style._alignment)
		Self.setShadowAlpha(style._shadowAlpha)
		Self.setShadowDistance(style._shadowXDistance, style._shadowYDistance)
		
		' Set these directly as they're ints, not (r,g,b) sets
		Self._shadowColor = style._shadowColor
		Self._fontColor = style._fontColor
		
		' Camera control
		Self.ignoreCamera(style._ignoreCamera)
		
		' Optional
		If style._font <> Null Then Self.setFont(style._font)
		If style._width <> -1 Then Self.setWidth(style._width)
		
		Return Self
		
	End Method
	
	''' <summary>Set the text to display.</summary>
	Method setText:TextRenderRequest(text:String)
		Self._text = text
		
		If Self._wrap Then
			Self._text = Self._wrapText(Self._text)
		End If
		
		Return Self
	End Method
	
	''' <summary>Enable or disable text wrapping.</summary>
	Method setWrap:TextRenderRequest(wrap:Byte)
		Self._wrap = wrap
		Return Self
	End Method
	
	''' <summary>Set the dimensions of the request.</summary>
	Method setDimensions:TextRenderRequest(w:Float, h:Float)
		Self._width  = w
		Self._height = h
		Return Self
	End Method
	
	''' <summary>Set the text alignment. Can be left, right or center aligned.</summary>
	''' <param name="align">Text alignment. Use the ALIGN_ constants defined in this type.</param>
	''' <return>TextRenderRequest object.</return>
	Method setAlignment:TextRenderRequest(align:Byte)
		Self._alignment = align
		Return Self
	End Method
	
	Method setFont:TextRenderRequest(font:TImageFont)
		Self._font = font
		Return Self
	End Method
	
	Method setFontColor:TextRenderRequest(r:Byte, g:Byte, b:Byte)
		Self._fontColor = PangolinGfx.rgbToInt(r, g, b)
		Return Self
	End Method
	
	Method setShadowColor:TextRenderRequest(r:Byte, g:Byte, b:Byte)
		Self._shadowColor = PangolinGfx.rgbToInt(r, g, b)
		Return Self
	End Method
	
	Method setShadowAlpha:TextRenderRequest(alpha:Float)
		Self._shadowAlpha = alpha
		Return Self
	End Method

	Method setShadowDistance:TextRenderRequest(xDistance:Int, yDistance:Int)
		Self._shadowXDistance = xDistance
		Self._shadowYDistance = yDistance
		Return Self
	End Method
	
	Method setWidth:TextRenderRequest(width:Float)
		Self._width = width
		Return Self
	End Method
	
	
	' ------------------------------------------------------------
	' -- Querying
	' ------------------------------------------------------------

	Method getText:String()
		Return Self._text	
	End Method

		
	' ------------------------------------------------------------
	' -- Rendering
	' ------------------------------------------------------------
	
	' [todo] - Needs to take the camera into account
	
	Method render(tween:Double, camera:AbstractRenderCamera, isFixed:Int = False)
		
		' Don't render if no text or set to invisible
		If Self._text = "" Or Self.isVisible() = False Then
			Return
		EndIf
		
		' Calculate new position
		Self._interpolate(1)
		
		' Store previous font for restoration
		Local oldFont:TImageFont = GetImageFont()
		
		' Set up appearance
		Self.setRenderState()
		If Self._font Then SetImageFont(Self._font)
		
		' Wrap the text (if required)
		If Self._wrap Then
			
			' Add new lines to wrapped text and split it
			' [todo] - Only wrap text when something is changed - it's slow!
			Local wrappedText:String = Self._text
			
			Local lines:String[] = wrappedText.Split("~n")
			Local yPos:Float = Self._currentPosition._yPos
			Local h:Float = TextHeight("`j")
			
			' Limit viewport when wrapping
			' [todo] - do we need this?
		'	SetViewport Self._tweenedPosition._xPos, Self._tweenedPosition._yPos, Self._width, Self._height
			
			For Local line:String = EachIn lines
				Self.renderTextLine(line, Self._tweenedPosition._xPos, yPos)
				yPos:+ h
			Next
			
		'	SetViewport(0, 0, PangolinGfx.getGraphicsWidth(), PangolinGfx.getGraphicsHeight())
		Else
			Self.renderTextLine(Self._text, Self._tweenedPosition._xPos, Self._tweenedPosition._yPos)
		End If
		
		' Reset appearance
		SetImageFont(oldFont)
		
	End Method
	
	Method renderTextLine(line:String, xOff:Float, yOff:Float)
		
		If Self._alignment = ALIGN_CENTER Then
			xOff:+ ((Self._width - TextWidth(line)) / 2)
		ElseIf Self._alignment = ALIGN_RIGHT Then
			xOff = xOff + Self._width - TextWidth(line)
		End If
		
		' Draw the font
		If Self._shadowColor <> -1 Then
			PangolinGfx.SetColorInt(Self._shadowColor)
			Local oldAlpha:Float = brl.max2d.GetAlpha()
			brl.max2d.SetAlpha(Self._shadowAlpha)
			DrawText line, xOff + Self._shadowXDistance, yOff + Self._shadowyDistance
			brl.max2d.SetAlpha(oldAlpha)
		EndIf
		
		PangolinGfx.SetColorInt(Self._fontColor)
		DrawText line, xOff, yOff
		
	End Method
	
	Method _wrapText:String(text:String)
		
		Local wrappedText:String = ""
		Local currentLine:String = ""
		Local currentWord:String = ""
		
		For Local pos:Int = 1 To text.Length
			If Mid(text, pos, 1) = " " Then
				If TextWidth(currentLine + " " + currentWord) > Self._width Then
					wrappedText:+ currentLine + "~n"
					currentLine = currentWord + " "
					currentWord = ""
				Else
					currentLine:+ currentWord + " "
					currentWord = ""
				EndIf
			ElseIf Mid(text, pos, 1) = "~n" Then
				wrappedText:+ currentLine + currentWord + "~n"
				currentLine = ""
				currentWord = ""
			Else
				currentWord:+ Trim(Mid(text, pos, 1))
			EndIf
		Next
		
		wrappedText:+ currentLine + currentWord
		
		Return wrappedText
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------
	
	Function Create:TextRenderRequest(text:String, xPos:Int, yPos:Int, style:TextRenderStyle = Null)
		Local this:TextRenderRequest = New TextRenderRequest
		this.setText(text)
		this.setPosition(xPos, yPos)
		
		If style Then this.setStyle(style)
		
		Return this
	End Function
	
End Type
