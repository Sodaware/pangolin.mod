' ------------------------------------------------------------------------------
' -- src/exceptions.bmx
' --
' -- Exceptions for the state machine system.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2020 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type StateMachineException Extends TBlitzException

End Type

Type LockedStateMachineException Extends StateMachineException
	Method toString:String()
		Return "Cannot add more states to a locked state machine"
	End Method
End Type

Type EmptyAutoloadTagException Extends StateMachineException
	Method toString:String()
		Return "Cannot autoload empty tag"
	End Method
End Type

Type MissingStateException Extends StateMachineException
	Field _state:String

	Method toString:String()
		Return "State '" + Self._state + "' is not registered with this state machine"
	End Method

	Function Create:MissingStateException(state:String)
		Local exception:MissingStateException = New MissingStateException

		exception._state = state

		Return exception
	End Function
End Type

Type MissingStateTransitionException Extends StateMachineException
	Field _transition:String

	Method toString:String()
		Return "Transition '" + Self._transition + "' is not registered with this state machine"
	End Method

	Function Create:MissingStateTransitionException(transition:String)
		Local exception:MissingStateTransitionException = New MissingStateTransitionException

		exception._transition = transition

		Return exception
	End Function
End Type

Type InvalidTransitionForStateException Extends StateMachineException
	Field _state:String
	Field _transition:String

	Method toString:String()
		Return "Cannot run transition '" + Self._transition + "' from state '" + Self._state + "'"
	End Method

	Function Create:InvalidTransitionForStateException(transition:String, state:String)
		Local exception:InvalidTransitionForStateException = New InvalidTransitionForStateException

		exception._state      = state
		exception._transition = transition

		Return exception
	End Function
End Type

Type StateHandlerAlreadyRegisteredException Extends StateMachineException
	Field _state:String

	Method toString:String()
		Return "Cannot have multiple handlers for the same state ('" + Self._state + "')"
	End Method

	Function Create:StateHandlerAlreadyRegisteredException(state:String)
		Local exception:StateHandlerAlreadyRegisteredException = New StateHandlerAlreadyRegisteredException

		exception._state = state

		Return exception
	End Function
End Type
