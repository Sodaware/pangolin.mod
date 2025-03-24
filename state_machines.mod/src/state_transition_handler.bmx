' ------------------------------------------------------------------------------
' -- pangolin.state_machines - src/state_transition_handler.bmx
' --
' -- Base type for handling transitions in a state machine.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2019 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


''' <summary>
''' Base type for handling transitions in a state machine.
'''
''' For use with Screens and entities, you will probably want to extend this
''' screen with some helpers.
''' </summary>
Type StateTransitionHandler
	Field _isFinished:Byte      '''< Is the handler finished?
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

	' TODO: Change this to something event based?
	Method isFinished:Byte()
		Return Self._isFinished
	End Method

	Method andThen(transition:String)
		Self._parent.andThen(transition)
	End Method

	Method finish()
		Self._isFinished = True
	End Method

	Method start()

	End Method

	Method update(delta:Float, noFocus:Byte = False, covered:Byte = False)
	End Method

	Method reset()
		Self._isFinished = False
	End Method
End Type
