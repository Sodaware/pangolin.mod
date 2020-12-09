' ------------------------------------------------------------------------------
' -- src/util/graphics_util.bmx
' --
' -- Various utility functions for working with graphics.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.max2d

Function GetVirtualScale(xScale:Float var, yScale:Float var)
	xScale = GraphicsWidth() / VirtualResolutionWidth()
	yScale = GraphicsHeight() / VirtualResolutionHeight()
End Function

Function GetAspectRatio:Float()
	Return (Float(GraphicsHeight()) / Float(GraphicsWidth()))
End Function

Function SetColorInt(color:Int)
	SetColor 255 & (color Shr 16), 255 & (color Shr 8), 255 & color
End Function

Function IntToRgb(color:Int, r:Byte Var, g:Byte Var, b:Byte Var)
	r = color Shr 16
	g = color Shr 8
	b = color
End Function

Function RgbToInt:Int(r:Byte, g:Byte, b:Byte)
	Return ColorRgb(r, g, b)
End Function

''' <summary>Convert an RGB colour into a single integer.</summary>
''' <param name="r">Red value between 0 and 255.</param>
''' <param name="g">Green value between 0 and 255.</param>
''' <param name="b">Blue value between 0 and 255.</param>
''' <returns>Integer colour.</returns>
Function ColorRgb:Int(r:Byte, g:Byte, b:Byte)
	Return (r Shl 16) + (g Shl 8) + (b)
End Function

''' <summary>Check if the current screen resolution widescreen.</summary>
''' <returns>True if the screen is widescreen (the aspect ratio >= 1.6).</returns>
Function IsWidescreen:Byte()
	Return GetAspectRatio() >= 1.6
End Function

Function TileImageScaled(image:TImage, x:Float = 0, y:Float = 0, frame:Int = 0)

	' Get the current scale, viewport, origin and handle
    Local scaleX:Float
	Local scaleY:Float
    GetScale(scaleX, scaleY)

    Local viewportX:Int
	Local viewPortY:Int
	Local viewportWidth:Int
	Local viewportHeight:Int
    GetViewport(viewportX, viewPortY, viewportWidth, viewportHeight)

    Local originX:Float
    Local originY:Float
    GetOrigin(originX, originY)

    Local handleX:Float
	Local handleY:Float
    GetHandle(handleX, handleY)

    Local imgHeight:Float = ImageHeight(image)
    Local imgWidth:Float  = ImageWidth(image)

    Local width:Float  = imgWidth * Abs(scaleX)
    Local height:Float = imgHeight * Abs(scaleY)

    Local ox:Float = viewportX - width + 1
    Local oy:Float = viewportY - height + 1

    originX = originX Mod width
    originY = originY Mod height

    Local px:Float = x + originX - handleX
    Local py:Float = y + originY - handleY

    Local fx:Float = px - Floor(px)
    Local fy:Float = py - Floor(py)
    Local tx:Float = Floor(px) - ox
    Local ty:Float = Floor(py) - oy

    If tx>=0 tx=tx Mod width + ox Else tx = width - -tx Mod width + ox
    If ty>=0 ty=ty Mod height + oy Else ty = height - -ty Mod height + oy

    Local vr:Float = viewportX + viewportWidth, vb# = viewportY + viewportHeight

    SetOrigin 0,0
    Local iy#=ty
    While iy<vb + height ' add image height to fill lower gap
        Local ix#=tx
        While ix<vr + width ' add image width to fill right gap
            DrawImage(image, ix+fx,iy+fy, frame)
            ix=ix+width
        Wend
        iy=iy+height
    Wend
    SetOrigin originX, originY

End Function
