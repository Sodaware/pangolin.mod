' ------------------------------------------------------------------------------
' -- src/behaviour/flash_sprite_animation.bmx
' --
' -- Flash a sprite.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "sprite_behaviour.bmx"

Type FlashSpriteBehaviour Extends SpriteBehaviour
	Field _displayTime:Float
	Field _hideTime:Float
	Field _repeatLimit:Int
	Field _timer:Float

	' -- Internal
	Field _repeatCount:Int


	' ------------------------------------------------------------
	' -- Setting Options
	' ------------------------------------------------------------

	Method setDisplayTime:FlashSpriteBehaviour(time:Float)
		Self._displayTime = time

		Return Self
	End Method

	Method setHideTime:FlashSpriteBehaviour(time:Float)
		Self._hideTime = time

		Return Self
	End Method

	Method setRepeatLimit:FlashSpriteBehaviour(limit:Int)
		Self._repeatLimit = limit

		Return Self
	End Method


	' ------------------------------------------------------------
	' -- Updating
	' ------------------------------------------------------------

	Method update(delta:Float)
		Super.update(delta)

		Self._timer :+ delta

		If Self.getTarget().isVisible() Then
			If Self._timer >= Self._displayTime Then
				Self._timer :- Self._displayTime
				Self.getTarget().hide()
			EndIf
		Else
			If Self._timer >= Self._hideTime Then
				Self._timer :- Self._hideTime
				Self.getTarget().show()

				Self._repeatCount :+ 1
			EndIf
		EndIf
	End Method

	Method isFinished:Byte()
		Return ( ..
			Self._repeatLimit <> -1 ..
			And ..
			Self._repeatCount >= Self._repeatLimit ..
		)
	End Method


	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------

	Function Create:FlashSpriteBehaviour(request:AbstractRenderRequest, displayTime:Float = 50, hideTime:Float = 50, repeatLimit:Int = -1)
		Local this:FlashSpriteBehaviour	= New FlashSpriteBehaviour

		this.setTarget(request)
		this.setDisplayTime(displayTime)
		this.setHideTime(hideTime)
		this.setRepeatLimit(repeatLimit)

		Return this
	End Function

End Type
