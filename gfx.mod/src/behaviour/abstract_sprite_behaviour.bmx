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

Type AbstractSpriteBehaviour Abstract
	
	Const TRANSITION_LINEAR:Byte 		= 1
	Const TRANSITION_EASE_IN:Byte 		= 2
	Const TRANSITION_EASE_OUT:Byte 		= 3
	Const TRANSITION_EASE_IN_OUT:Byte 	= 4
	
	Field _transitionType:Byte
	Field _transitionFunction:Float(t:Float, s:Float, de:Float, du:Float)
	Field _elapsedTime:Float
	
	Field _isFinished:Byte	= False

	Method isFinished:Byte()
		Return Self._isFinished
	End Method
	
	Method finished()
		Self._isFinished = True
	End Method
	
	Method setTransition(transition:Byte)
		
		Self._transitionType = transition
		
		Select transition
		
			Case TRANSITION_LINEAR
				Self._transitionFunction = TransitionFunction_Linear
				
			Case TRANSITION_EASE_IN
				Self._transitionFunction = TransitionFunction_EaseIn
				
		End Select
		
	End Method
	
	Method setTarget(target:Object) Abstract
	Method update(delta:Float) Abstract
	
	Method onStart()
		
	End Method
	
	Method onFinish()
		
	End Method
	
	' ----------------------------------------------------------------------
	' -- Transition functions
	' ----------------------------------------------------------------------
	
	Function TransitionFunction_Linear:Float(time:Float, start:Float, delta:Float, duration:Float)
		Return start + (time * delta)
	End Function
	
	Function TransitionFunction_EaseIn:Float(time:Float, start:Float, delta:Float, duration:Float)
		Return start + (time * time * delta)
	End Function


End Type