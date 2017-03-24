' ------------------------------------------------------------------------------
' -- src/util/graphics_util.bmx
' --
' -- Various utility finctions for working with graphics.
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


Function SetColorInt(color:int)
	SetColor 255 & (color SHR 16), 255 & (color SHR 8), 255 & color
End Function

function ColorRgb:int(r:byte, g:byte, b:byte)
	return (r shl 16) + (g shl 8) + (b)
end function


Function IsWidescreen:Int()
	Return (GraphicsHeight() / GraphicsWidth() >= 1.6)
End Function

Function TileImageScaled(image:TImage, x:Float = 0 ,y:Float = 0, frame:Int = 0)

    Local scale_x#, scale_y#
    GetScale(scale_x#, scale_y#)

    Local viewport_x%, viewport_y%, viewport_w%, viewport_h%
    GetViewport(viewport_x, viewport_y, viewport_w, viewport_h)

    Local origin_x#, origin_y#
    GetOrigin(origin_x, origin_y)

    Local handle_X#, handle_y#
    GetHandle(handle_X#, handle_y#)

    Local image_h# = ImageHeight(image)
    Local image_w# = ImageWidth(image)

    Local w#=image_w * Abs(scale_x#)
    Local h#=image_h * Abs(scale_y#)

    Local ox#=viewport_x-w+1
    Local oy#=viewport_y-h+1

    origin_X = origin_X Mod w
    origin_Y = origin_Y Mod h

    Local px#=x+origin_x - handle_x
    Local py#=y+origin_y - handle_y

    Local fx#=px-Floor(px)
    Local fy#=py-Floor(py)
    Local tx#=Floor(px)-ox
    Local ty#=Floor(py)-oy

    If tx>=0 tx=tx Mod w + ox Else tx = w - -tx Mod w + ox
    If ty>=0 ty=ty Mod h + oy Else ty = h - -ty Mod h + oy

    Local vr#= viewport_x + viewport_w, vb# = viewport_y + viewport_h

    SetOrigin 0,0
    Local iy#=ty
    While iy<vb + h ' add image height to fill lower gap
        Local ix#=tx
        While ix<vr + w ' add image width to fill right gap
            DrawImage(image, ix+fx,iy+fy, frame)
            ix=ix+w
        Wend
        iy=iy+h
    Wend
    SetOrigin origin_x, origin_y

End Function
