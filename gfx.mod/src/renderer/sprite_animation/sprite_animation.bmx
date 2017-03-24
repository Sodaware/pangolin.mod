' ------------------------------------------------------------------------------
' -- src/renderer/sprite_animation/sprite_animation.bmx
' --
' -- Base sprite animation that updates an AbstractSpriteRequest.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../abstract_sprite_request.bmx"
Import "abstract_sprite_animation.bmx"

Type SpriteAnimation Extends AbstractSpriteAnimation

	Field _parent:AbstractSpriteRequest
	
	
	Method setParent(parent:Object)
		Self._parent = AbstractSpriteRequest( parent )
	End Method
	
	Method getParent:AbstractSpriteRequest()
		Return Self._parent
	End Method
	
	Method update(delta:Float)
		
	End Method
	
	Method preRender(delta:Float)  ; End Method
	Method postRender(delta:Float) ; End Method
	
End Type
