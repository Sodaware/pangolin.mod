' ------------------------------------------------------------------------------
' -- pangolin.state_machines - src/state_handler.bmx
' --
' -- Base type for updating states in a state machine.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2020 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


''' <summary>
''' Base type for updating states in a state.
'''
''' All `StateHandler` instances can update and handleInput, but only if the
''' parent state machine calls these methods.
'''
''' Updating and input handling work the same way as in `IGameScreen`.
''' </summary>
Type StateHandler
	Field _target:Object        '''< The object the handler is attached to.
	Field _parent:StateMachine  '''< The parent state machine for this handler.

	''' <summary>
	''' Called when the state handler is added to a state machine.
	'''
	''' The target variable has been set when this is called, so it's safe to
	''' reference it.
	''' </summary>
	Method initialize()
	End Method

	''' <summary>
	''' Called every time the state is entered.
	'''
	''' Use this to run code that needs to happen every time the state is
	''' entered, regardless of the transition.
	''' </summary>
	Method onEnter()
	End Method

	''' <summary>
	''' Called every time the state is exited.
	''' </summary>
	Method onExit()
	End Method

	Method update(delta:Float, noFocus:Byte = False, covered:Byte = False)
	End Method

	Method handleInput()
	End Method
End Type
