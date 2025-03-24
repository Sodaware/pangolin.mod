' ------------------------------------------------------------------------------
' -- pangolin.state_machines - src/state_transition.bmx
' --
' -- Wraps state transition information and links it to an object.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2019 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type StateTransition
	' TODO: Change "_from" to array.
	Field name:String
	Field _from:String[]
	Field _to:String
	Field _isFinished:Byte
	Field screen:Object
	
	Method start()
	End Method
		
	' TODO: Change this to something event based?
	Method isFinished:Byte()
		Return Self._isFinished
	End Method
	
	Method finish()
		Self._isFinished = True
	End Method

	Method addFromState:StateTransition(state:String)
		Self._from = Self._from[..Self._from.length + 1]
		Self._from[Self._from.length - 1] = state

		Return Self
	End Method

	Method New()

	End Method

	Method canTransitionFrom:Byte(name:String)
		For Local state:String = EachIn Self._from
			If name = state Then Return True
		Next

		Return False
	End Method

	Method init:StateTransition(name:String, fromState:String, toState:String)
		Self.addFromState(fromState)
		Self.name  = name
		Self._to   = toState
		
		Return Self
	End Method
		
	Function Create:StateTransition(name:String, fromState:String = "", toState:String = "")
		Local this:StateTransition = New StateTransition

		this.init(name, fromState, toState)

		Return this
	End Function
End Type
