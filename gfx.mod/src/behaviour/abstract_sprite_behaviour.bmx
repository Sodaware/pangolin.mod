' ------------------------------------------------------------------------------
' -- src/behaviour/abstract_sprite_behaviour.bmx
' --
' -- Base type that all sprite behaviours must extend.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.events

Type AbstractSpriteBehaviour Abstract
	' Built-in easing types.
	Const EASING_LINEAR:Byte        = 1
	Const EASING_EASE_IN:Byte       = 2
	Const EASING_EASE_OUT:Byte      = 3
	Const EASING_EASE_IN_OUT:Byte   = 4

	Field _elapsedTime:Float
	Field _duration:Float
	Field _isFinished:Byte = False


	Field _easingType:Byte
	Field _easingFunction:Float(t:Float, s:Float, f:Float, d:Float)

	' Hooks that are called when the behaviour has finished.
	Field _whenFinishedHooks:EventHandlerBag = New EventHandlerBag

	' --------------------------------------------------
	' -- Required Methods
	' --------------------------------------------------

	Method setTarget(target:Object) Abstract
	Method update(delta:Float) Abstract


	' --------------------------------------------------
	' -- Standard PI
	' --------------------------------------------------

	''' <summary>Set the duration of the behaviour.</summary>
	Method setDuration:AbstractSpriteBehaviour(duration:Float)
		Self._duration = duration

		Return Self
	End Method

	Method isFinished:Byte()
		Return Self._isFinished
	End Method

	Method finished()
		Self._isFinished = True
	End Method


	' --------------------------------------------------
	' -- Easing Helpers
	' --------------------------------------------------

	''' <summary>
	''' Set the easing type to use from the built-in options.
	'''
	''' There are four easing types available: Linear (the default), ease-in,
	''' ease-out, and ease-in-out.
	'''
	''' Use `setEasingFunction` to pass in a custom easing function instead of
	''' using a built-in one.
	''' </summary>
	Method setEasingType:AbstractSpriteBehaviour(easing:Byte)
		' TODO: Throw an exception if an invalid easing type is passed in.
		Self._easingType = easing

		Select easing

			Case EASING_LINEAR
				Self.setEasingFunction(EasingFunction_Linear)

			Case EASING_EASE_IN
				Self.setEasingFunction(EasingFunction_EaseIn)

			Case EASING_EASE_OUT
				Self.setEasingFunction(EasingFunction_EaseOut)

			Case EASING_EASE_IN_OUT
				Self.setEasingFunction(EasingFunction_EaseInOut)

		End Select

		Return Self
	End Method

	Method setEasingFunction(fn:Float(t:Float, s:Float, f:Float, d:Float))
		Self._easingFunction = fn
	End Method

	''' <summary>
	''' Tween a value.
	'''
	''' Uses the behaviour's built-in timer and duration values.
	''' </summary>
	''' <param name="startValue">The initial value of the tween.</param>
	''' <param name="finalValue">The final value we want to tween to.</param>
	''' <return>The tweened value.</return>
	Method tween:Float(startValue:Float, finalValue:Float)
		Return Self.tweenValue(Self._elapsedTime, startValue:Float, finalValue:Float, Self._duration)
	End Method

	''' <summary>
	''' Tween a value.
	'''
	''' Defaults to a linear easing function if one hasn't been set.
	''' </summary>
	''' <param name="time">The elapsed time.</param>
	''' <param name="startValue">The initial value of the tween.</param>
	''' <param name="finalValue">The final value we want to tween to.</param>
	''' <param name="duration">The total duration this easing happens over.</param>
	''' <return>The eased value.</return>
	Method tweenValue:Float(time:Float, startValue:Float, finalValue:Float, duration:Float)
		If Self._easingFunction Then
			Return Self._easingFunction(time, startValue, finalValue, duration)
		Else
			Return EasingFunction_Linear(time, startValue, finalValue, duration)
		EndIf
	End Method


	' --------------------------------------------------
	' -- Optional Hooks
	' --------------------------------------------------

	''' <summary>Called when the sprite behaviour has first started.</summary>
	Method onStart()

	End Method

	''' <summary>Called when the sprite behaviour has finished.</summary>
	Method onFinish()
		Self._whenFinishedHooks.runAll(Null)
	End Method

	Method whenFinished:AbstractSpriteBehaviour(callback:EventHandler)
		Self._whenFinishedHooks.add(callback)

		Return Self
	End Method


	' --------------------------------------------------
	' -- Easing Functions
	' --------------------------------------------------

	Function EasingFunction_Linear:Float(time:Float, start:Float, change:Float, duration:Float)
		Return change * (time / duration) + start
	End Function

	Function EasingFunction_EaseIn:Float(time:Float, start:Float, change:Float, duration:Float)
		Return change * ((time / duration) ^ 2) + start
	End Function

	Function EasingFunction_EaseOut:Float(time:Float, start:Float, change:Float, duration:Float)
		time = time / duration

		Return -change * time * (time - 2) + start
	End Function

	Function EasingFunction_EaseInOut:Float(time:Float, start:Float, change:Float, duration:Float)
		time = time / duration * 2

		If time < 1 Then Return change / 2 * (time ^ 2) + start

		Return -change / 2 * ((time - 1) * (time - 3) - 1) + start
	End Function

End Type
