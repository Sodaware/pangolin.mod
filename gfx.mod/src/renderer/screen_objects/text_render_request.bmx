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

	Const ALIGN_LEFT:Byte           = 1
	Const ALIGN_CENTER:Byte         = 2
	Const ALIGN_RIGHT:Byte          = 3

	Field _text:String
	Field _wrap:Byte                = False

	Field _font:TImageFont
	Field _width:Float
	Field _height:Float

	Field _fontColor:Int            = 0
	Field _shadowColor:Int          = -1
	Field _shadowAlpha:Float        = 0.5
	Field _shadowXDistance:Short    = 1
	Field _shadowYDistance:Short    = 1
	Field _alignment:Byte           = ALIGN_LEFT
	Field _lineHeight:Float         = -1

	' Internal state
	Field _oldFont:TImageFont
	Field _textWidth:Int            = -1
	Field _textHeight:Float


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

		' Camera control.
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

		Self._textWidth = -1

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

	''' <summary>Set the font this render request will use.</summary>
	''' <param name="font">The image font to use.</param>
	Method setFont:TextRenderRequest(font:TImageFont)
		Self._font = font

		Return Self
	End Method

	''' <summary>Set the color of the text.</summary>
	''' <param name="r">Red value of the text colour.</param>
	''' <param name="g">Green value of the text colour.</param>
	''' <param name="b">Blue value of the text colour.</param>
	Method setFontColor:TextRenderRequest(r:Byte, g:Byte, b:Byte)
		Self._fontColor = PangolinGfx.RgbToInt(r, g, b)

		Return Self
	End Method

	''' <summary>Set the color of the text using hex notation.</summary>
	''' <param name="color">Text colour in hex.</param>
	Method setFontColorHex:TextRenderRequest(color:String)
		Self._fontColor = HexToInt(color)

		Return Self
	End Method

	''' <summary>Set the color of the shadow.</summary>
	''' <param name="r">Red value of the shadow colour.</param>
	''' <param name="g">Green value of the shadow colour.</param>
	''' <param name="b">Blue value of the shadow colour.</param>
	Method setShadowColor:TextRenderRequest(r:Byte, g:Byte, b:Byte)
		Self._shadowColor = PangolinGfx.RgbToInt(r, g, b)
		Return Self
	End Method

	''' <summary>Set the shadow color using hex notation.</summary>
	''' <param name="color">Shadow colour in hex.</param>
	Method setShadowColorHex:TextRenderRequest(color:String)
		Self._shadowColor = HexToInt(color)
		Return Self
	End Method

	''' <summary>Set the alpha (opacity) of the text shadow.</summary>
	''' <param name="alpha">
	''' Shadow alpha value value between 0 and 1. 0 is totally transparent
	''' and 1 is completely opaque.
	''' </param>
	Method setShadowAlpha:TextRenderRequest(alpha:Float)
		Self._shadowAlpha = alpha
		Return Self
	End Method

	''' <summary>Set the shadow distance.</summary>
	''' <param name="xDistance">X distance of the shadow in pixels.</param>
	''' <param name="yDistance">Y distance of the shadow in pixels.</param>
	Method setShadowDistance:TextRenderRequest(xDistance:Int, yDistance:Int)
		Self._shadowXDistance = xDistance
		Self._shadowYDistance = yDistance
		Return Self
	End Method

	''' <summary>
	''' Set the width of the text render request. If wrapping is enabled, text
	''' will wrap once it hits the set width.
	''' </summary>
	''' <param name="width">Width of the request in pixels.</param>
	Method setWidth:TextRenderRequest(width:Float)
		Self._width = width

		Return Self
	End Method

	Method setLineHeight:TextRenderRequest(height:Float)
		Self._lineHeight = height

		Return Self
	End Method


	' ------------------------------------------------------------
	' -- Querying
	' ------------------------------------------------------------

	''' <summary>Get the text that will be displayed.</summary>
	Method getText:String()
		Return Self._text
	End Method

	Method getTextWidth:Int()
		If Self._textWidth = -1 Then
			Self._refreshTextWidth()
		End If
		Return Self._textWidth
	End Method

	Method getTextHeight:Float()
		Return Self._textHeight
	End Method


	' ------------------------------------------------------------
	' -- Rendering
	' ------------------------------------------------------------

	' [todo] - Needs to take the camera into account

	Method render(tween:Double, camera:AbstractRenderCamera, isFixed:Byte = False)
		' Don't render if set to invisible.
		If Self._isVisible = False Then Return

		' Calculate new position.
		Self._interpolate(1)
		Self.setRenderState()
		brl.max2d.SetBlend(alphablend)

		' Setup the font.
		If Self._oldFont <> Self._font And Self._font Then
			Self._oldFont = GetImageFont()
			SetImageFont(Self._font)
		EndIf

		' Set up appearance.
		' TODO: Is this really needed? It's rather slow. Maybe only set the state if something fancy is going on?
		' Self.setRenderState()

		' Wrap the text (if required)
		If Self.needsWrap() Then
			' Add new lines to wrapped text and split it.
			' [todo] - Only wrap text when something is changed - it's slow!
			Local wrappedText:String = Self._text

			Local lines:String[] = wrappedText.Split("~n")
			Local yPos:Float = Self._currentPosition._yPos

			' Limit viewport when wrapping
			' [todo] - do we need this?
			'	SetViewport Self._tweenedPosition._xPos, Self._tweenedPosition._yPos, Self._width, Self._height
			If Self._lineHeight = -1 Then
				Self._lineHeight = TextHeight("`j")
			EndIf

			For Local line:String = EachIn lines
				Self.renderTextLine(line, Self._tweenedPosition._xPos, yPos)
				yPos:+ Self._lineHeight
			Next

		'	SetViewport(0, 0, PangolinGfx.getGraphicsWidth(), PangolinGfx.getGraphicsHeight())
		Else
			Self.renderTextLine(Self._text, Self._tweenedPosition._xPos, Self._tweenedPosition._yPos)
		End If

		' Reset appearance
		If Self._oldFont Then
			SetImageFont(Self._oldFont)
		End If

	End Method

	Method renderTextLine(line:String, xOff:Float, yOff:Float)

		If Self._alignment = ALIGN_CENTER Then
			xOff:+ ((Self._width - TextWidth(line)) / 2)
		ElseIf Self._alignment = ALIGN_RIGHT Then
			xOff = xOff + Self._width - TextWidth(line)
		End If

		' Draw the shadow first (if present).
		If Self._shadowColor <> -1 Then
			PangolinGfx.SetColorInt(Self._shadowColor)
			Local oldAlpha:Float = brl.max2d.GetAlpha()
			brl.max2d.SetAlpha(Self._shadowAlpha)
			DrawText line, xOff + Self._shadowXDistance, yOff + Self._shadowyDistance
			brl.max2d.SetAlpha(oldAlpha)
		EndIf

		' Render the main text.
		PangolinGfx.SetColorInt(Self._fontColor)
		DrawText line, xOff, yOff

	End Method

	' TODO: Cache this
	Method needsWrap:Byte()
		Return Self._wrap Or Self._text.Contains("~n")
	End Method

	Method _wrapText:String(text:String)
		' Setup the font.
		If Self._oldFont <> Self._font And Self._font Then
			Self._oldFont = GetImageFont()
			SetImageFont(Self._font)
		EndIf

		Local wrappedText:String = ""
		Local currentLine:String = ""
		Local currentWord:String = ""
		Local lineCount:Int      = 1

		For Local pos:Int = 1 To text.Length
			If Mid(text, pos, 1) = " " Then
				If TextWidth(currentLine + " " + currentWord) >= Self._width Then
					wrappedText:+ currentLine + "~n"
					currentLine = currentWord + " "
					currentWord = ""
					lineCount :+ 1
				Else
					currentLine:+ currentWord + " "
					currentWord = ""
				EndIf
			ElseIf Mid(text, pos, 1) = "~n" Then
				wrappedText:+ currentLine + currentWord + "~n"
				currentLine = ""
				currentWord = ""
				lineCount :+ 1
			Else
				currentWord:+ Trim(Mid(text, pos, 1))
			EndIf
		Next

		' Check if final word takes us over the limit.
		If TextWidth(currentLine + " " + currentWord) >= Self._width Then
			wrappedText :+ currentLine + "~n" + currentWord
			lineCount :+ 1
		Else
			wrappedText :+ currentLine + currentWord
		EndIf

		Self._textHeight = TextHeight(wrappedText) * lineCount

		' Reset appearance
		If Self._oldFont Then
			SetImageFont(Self._oldFont)
		End If

		Return wrappedText

	End Method

	' SLOW.
	Method _refreshTextWidth()
		' Setup the font.
		If Self._oldFont <> Self._font And Self._font Then
			Self._oldFont = GetImageFont()
			SetImageFont(Self._font)
		EndIf

		Self._textWidth = TextWidth(Self._text)

		' Reset appearance
		If Self._oldFont Then
			SetImageFont(Self._oldFont)
		End If
	End Method


	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------

	Function Create:TextRenderRequest(text:String, xPos:Float, yPos:Float, style:TextRenderStyle = Null)
		Local this:TextRenderRequest = New TextRenderRequest
		this.setText(text)
		this.setPosition(xPos, yPos)

		If style Then this.setStyle(style)

		Return this
	End Function

End Type
