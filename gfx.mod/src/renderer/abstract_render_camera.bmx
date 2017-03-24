' ------------------------------------------------------------------------------
' -- src/renderer/abstract_render_camera.bmx
' --
' -- Base type that all render cameras must extend.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../util/position.bmx"
Import "../util/rectangle.bmx"

Type AbstractRenderCamera Abstract
	
	Method getX:Float() Abstract
	Method getY:Float() Abstract
	Method getWidth:Float() Abstract
	Method getHeight:Float() Abstract
	
	Method getPosition:Position2D() Abstract
	Method getBounds:Rectangle2D() Abstract
	
End Type
