SuperStrict
Framework BaH.MaxUnit

Import pangolin.state_machines

New TTestSuite.run()

Type Pangolin_StateMachines_StateMachineTests Extends TTest
	Field subject:StateMachine

	Method setup() { before }
		Self.subject = New StateMachine
	End Method

	Method tearDown() { after }
		Self.subject = Null
	End Method


	' ------------------------------------------------------------
	' -- #getCurrentStateName
	' ------------------------------------------------------------

	Method testGetCurrentStateNameReturnsEmptyStringForNewStateMachine() { test }
		Self.assertEquals("", Self.subject.getCurrentStateName())
	End Method


	' ------------------------------------------------------------
	' -- #getParent
	' ------------------------------------------------------------

	Method testGetParentReturnsNullWhenNoParent() { test }
		Self.assertNull(Self.subject.getParent())
	End Method


	' ------------------------------------------------------------
	' -- #addState
	' ------------------------------------------------------------

	Method testAddStateDoesNotAddEmptyStateNames() { test }
		Self.subject.addState("")
		Self.assertFalse(Self.subject.hasState(""))
	End Method

	Method testAddStateAddsValidStateNames() { test }
		Self.subject.addState("test_state")
		Self.assertTrue(Self.subject.hasState("test_state"))
	End Method


	' ------------------------------------------------------------
	' -- #addStates
	' ------------------------------------------------------------

	Method testAddStatesDoesNotAddEmptyStateNames() { test }
		Self.subject.addStates(["", "test", ""])
		Self.assertFalse(Self.subject.hasState(""))
		Self.assertTrue(Self.subject.hasState("test"))
	End Method

	Method testAddStatesAddsValidStateNames() { test }
		Self.subject.addStates(["test_state", "another"])
		Self.assertTrue(Self.subject.hasState("test_state"))
		Self.assertTrue(Self.subject.hasState("another"))
	End Method


	' ------------------------------------------------------------
	' -- #setInitialState
	' ------------------------------------------------------------

	' TODO: Cannot set a state name that doesn't exist.
	' TODO: Cannot set a state name if already has one.


	' ------------------------------------------------------------
	' -- #addTransition
	' ------------------------------------------------------------



	' ------------------------------------------------------------
	' -- Transitioning
	' ------------------------------------------------------------

	Method testCanTransitionFromOneValidStateToAnother() { test }
		Self.subject.addStates(["start", "finish"])
		Self.subject.addTransition("run_test", "start", "finish")
		Self.subject.setInitialState("start")

		Self.subject.transition("run_test")
	End Method


	' ------------------------------------------------------------
	' -- Locking/Unlocking
	' ------------------------------------------------------------

	Method testAddStateThrowsExceptionWhenStateMachineIsLocked() { test }
		Self.subject.lock()
		Try
			Self.subject.addState("test_state")
		Catch e:LockedStateMachineException
			' Test passes
		Catch e:Object
			Self.fail("addState did not throw correct exception")
		End Try
	End Method



	' ------------------------------------------------------------
	' -- .Create
	' ------------------------------------------------------------

	Method testCreateSetsParentObject() { test }
		Self.subject = StateMachine.Create(Self)
		Self.assertEquals(Self, Self.subject.getParent())
	End Method

End Type
