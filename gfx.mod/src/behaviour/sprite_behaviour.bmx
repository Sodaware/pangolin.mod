' ------------------------------------------------------------------------------
' -- sprite_animations/sprite_behaviour.bmx
' --
' -- Adds some helper methods for working with sprite behaviours.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../renderer/abstract_render_request.bmx"
Import "abstract_sprite_behaviour.bmx"

Type SpriteBehaviour Extends AbstractSpriteBehaviour

	Field _target:AbstractRenderRequest
	Field _hideOnFinish:Byte = False
	
	Method setTarget(target:Object)
		Self._target = AbstractRenderRequest(target)
	End Method
	
	Method getTarget:AbstractRenderRequest()
		Return Self._target
	End Method
	
	Method update(delta:Float)
		Self._elapsedTime :+ delta
	End Method
	
	Method preRender(delta:Float)
		
	End Method
	
	Method postRender(delta:Float)
		
	End Method
	
	Method hideOnFinish:SpriteBehaviour()
		Self._hideOnFinish = True
		Return Self
	End Method
	
	Method onFinish()
		Super.onFinish()
		If Self._hideOnFinish Then
			Self._target.hide()
		End If
	End Method
	
End Type
