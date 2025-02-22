SuperStrict

Framework BaH.MaxUnit

Import pangolin.actions

' Run tests.
New TTestSuite.run()

Type Pangolin_Actions_CallbackActionTests Extends TTest
	' Field used inside the callback.
	Field executed:Int = False

	Method setup() { before }
	End Method

	Method tearDown() { after }
	End Method

	Method testCallbackActionExecutesOnStart() { test }
		Local callback:EventHandler = Callback(Self, "setExecuted")
		Local action:CallbackAction = CallbackAction.Create(callback)

		Self.assertFalse(self.executed)

		action.onStart()

		Self.assertTrue(self.executed)
	End Method

	Method testCallbackActionMarksTestAsFinishedOnStart() { test }
		Local callback:EventHandler = Callback(Self, "setExecuted")
		Local action:CallbackAction = CallbackAction.Create(callback)

		Self.assertFalse(action.isFinished())

		action.onStart()

		Self.assertTrue(action.isFinished())
	End Method

	' Internal callback function to test
	Method setExecuted(data:Object = Null)
		executed = True
	End Method

End Type
