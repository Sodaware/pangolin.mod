' ------------------------------------------------------------------------------
' -- src/util/text_render_style.bmx
' --
' -- Type to hold a set of text styles that can be used by TextRenderRequest.
' -- Cuts down on repeating the same style declarations over and over.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../../pangolin_gfx.bmx"

Type TextRenderStyle
	
	Field _font:TImageFont
	
	Field _fontColor:Int            = 0
	Field _shadowColor:Int          = -1
	Field _shadowAlpha:Float        = 0.5
	Field _shadowXDistance:Short    = 1
	Field _shadowYDistance:Short    = 1
	Field _alignment:Byte           = 1
	Field _width:Float              = -1
	Field _ignoreCamera:Byte        = False
	
	
	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------
	
	''' <summary>Set the text alignment. Can be left, right or center aligned.</summary>
	''' <param name="align">Text alignment. Use the ALIGN_ constants defined in this type.</param>
	''' <return>TextRenderRequest object.</return>
	Method setAlignment:TextRenderStyle(align:Byte)
		Self._alignment = align
		Return Self
	End Method
	
	Method setFont:TextRenderStyle(font:TImageFont)
		Self._font = font
		Return Self
	End Method
	
	Method setFontColor:TextRenderStyle(r:Byte, g:Byte, b:Byte)
		Self._fontColor = PangolinGfx.rgbToInt(r, g, b)
		Return Self
	End Method
	
	Method setShadowColor:TextRenderStyle(r:Byte, g:Byte, b:Byte)
		Self._shadowColor = PangolinGfx.rgbToInt(r, g, b)
		Return Self
	End Method
	
	Method setShadowAlpha:TextRenderStyle(alpha:Float)
		Self._shadowAlpha = alpha
		Return Self
	End Method

	Method setShadowDistance:TextRenderStyle(xDistance:Int, yDistance:Int)
		Self._shadowXDistance = xDistance
		Self._shadowYDistance = yDistance
		Return Self
	End Method
	
	Method setWidth:TextRenderStyle(width:Float)
		Self._width = width
		Return Self
	End Method
	
	Method ignoreCamera:TextRenderStyle(ignore:Byte = True)
		Self._ignoreCamera = ignore
		Return Self
	End Method
	
End Type
