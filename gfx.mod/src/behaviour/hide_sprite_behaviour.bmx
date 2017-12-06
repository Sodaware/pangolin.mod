' ------------------------------------------------------------------------------
' -- src/behaviour/hide_sprite_behaviour.bmx
' --
' -- Hides a request. That's it. Mostly done so that `SequentialSpriteBehaviour`
' -- can be used to hide/show things in a sequence.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "sprite_behaviour.bmx"

Type HideSpriteBehaviour Extends SpriteBehaviour

	' ----------------------------------------------------------------------
	' -- Updating
	' ----------------------------------------------------------------------

	Method update(delta:Float)
		Self._target.hide()
		Self._isFinished = True
	End Method


	' ----------------------------------------------------------------------
	' -- Construction
	' ----------------------------------------------------------------------

	Function Create:HideSpriteBehaviour(request:AbstractRenderRequest)
		Local this:HideSpriteBehaviour = New HideSpriteBehaviour
		this.setTarget(request)
		Return this
	End Function

End Type
