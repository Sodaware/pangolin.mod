' ------------------------------------------------------------------------------
' -- sprite_animations/fade_sprite_in_animation.bmx
' --
' -- Fades a sprite in from a start and end alpha.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2020 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "sprite_behaviour.bmx"

Type FadeSpriteOutBehaviour Extends SpriteBehaviour
	Field _startAlpha:Float = 1
	Field _endAlpha:Float   = 0


	' ------------------------------------------------------------
	' -- Updating
	' ------------------------------------------------------------

	Method update(delta:Float)
		Super.update(delta)

		Self.getTarget().setAlpha(Self.tween(Self._startAlpha, Self._endAlpha))

		' If elapsed time is over, finish.
		If Self._elapsedTime >= Self._duration Then
			Self.getTarget().SetAlpha(Self._endAlpha)
			Self.finished()
		End If
	End Method


	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------

	Function Create:FadeSpriteOutBehaviour(request:AbstractRenderRequest, duration:Float)
		Local this:FadeSpriteOutBehaviour = New FadeSpriteOutBehaviour

		this.setTarget(request)
		this.setDuration(duration)

		Return this
	End Function
End Type
