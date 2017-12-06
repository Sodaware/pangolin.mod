' ------------------------------------------------------------------------------
' -- src/behaviour/hide_sprite_behaviour.bmx
' --
' -- Shows a request. That's it. Mostly done so that `SequentialSpriteBehaviour`
' -- can be used to hide/show things in a sequence.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "sprite_behaviour.bmx"

Type ShowSpriteBehaviour Extends SpriteBehaviour

	' ----------------------------------------------------------------------
	' -- Updating
	' ----------------------------------------------------------------------

	Method update(delta:Float)
		Self._target.show()
		Self._isFinished = True
	End Method


	' ----------------------------------------------------------------------
	' -- Construction
	' ----------------------------------------------------------------------

	Function Create:ShowSpriteBehaviour(request:AbstractRenderRequest)
		Local this:ShowSpriteBehaviour = New ShowSpriteBehaviour
		this.setTarget(request)
		Return this
	End Function

End Type
