SuperStrict

Framework BaH.MaxUnit

Import pangolin.actions

' Run tests.
New TTestSuite.run()

Type Pangolin_Actions_ParallelActionTests Extends TTest
	Field kernel:GameKernel
	Field service:TestService

	Method setup() { before }		
		Self.kernel  = new GameKernel
		Self.service = new TestService
		
		Self.kernel.addService(Null, Self.service)
	End Method
	
	Method tearDown() { after }
		Self.kernel = Null
	End Method

	' ------------------------------------------------------------
	' -- ParallelAction.add
	' ------------------------------------------------------------

	Method testAddAddsAction() { test }
		Local action:TestAction = new TestAction
		Local parallel:ParallelAction = ParallelAction.Create()
		
		Self.assertEqualsI(0, parallel.countActions())
		parallel.add(action)
		Self.assertEqualsI(1, parallel.countActions())
	End Method
		
	Method testAddCallsInitMethodOnAddedAction() { test }
		Local action:TestAction = new TestAction
		Local parallel:ParallelAction = ParallelAction.Create()

		Self.assertEqualsI(0, action.timesInitialized)
		parallel.add(action)
		Self.assertEqualsI(1, action.timesInitialized)
	End Method
	
	Method testAddSetsTheActionsKernel() { test }
		Local action:TestAction = new TestAction
		Local parallel:ParallelAction = ParallelAction.Create()
		parallel.setKernel(Self.kernel)

		Self.assertNull(action.getKernel())
		parallel.add(action)
		Self.assertNotNull(action.getKernel())
	End Method

	Method testAddAutowiresServices() { test }
		Local action:TestAction = new TestAction
		Local parallel:ParallelAction = ParallelAction.Create()
		
		parallel.setKernel(Self.kernel)

		Self.assertNull(action.service)
		parallel.add(action)
		Self.assertNotNull(action.service)
	End Method
	
	Method testAddRaisesExceptionIfActionIsNull() { test }
		Local parallel:ParallelAction = ParallelAction.Create()
		parallel.setKernel(Self.kernel)

		Try
			parallel.add(Null)
			Self.fail("This shouldn't be reached")
		Catch e:Pangolin_Actions_NullActionException
			Self.assertTrue(True)
		Catch e:Object
			Self.fail("Should be a strongly-typed Exception")
		End Try
	End Method
	

	' ------------------------------------------------------------
	' -- ParallelAction.onStart
	' ------------------------------------------------------------
	
	Method testParallelActionCallsOnStartForAllChildren() { test }
		' Create test actions
		Local action1:TestAction = new TestAction
		Local action2:TestAction = new TestAction
		
		' Create parallel action and add test actions.
		Local parallel:ParallelAction = ParallelAction.Create()
		parallel.add(action1)
		parallel.add(action2)
		
		Self.assertEqualsI(0, action1.timesStarted)
		Self.assertEqualsI(0, action2.timesStarted)

		parallel.onStart()
		
		Self.assertEqualsI(1, action1.timesStarted)
		Self.assertEqualsI(1, action2.timesStarted)
	End Method
	
	' ------------------------------------------------------------
	' -- ParallelAction.onFinish
	' ------------------------------------------------------------
	
	Method testParallelActionCallsOnFinishForAllChildren() { test }
		' Create test actions
		Local action1:TestAction = new TestAction
		Local action2:TestAction = new TestAction
		
		' Create parallel action and add test actions.
		Local parallel:ParallelAction = ParallelAction.Create()
		parallel.add(action1)
		parallel.add(action2)
		
		
		Self.assertEqualsI(0, action1.timesFinished)
		Self.assertEqualsI(0, action2.timesFinished)

		parallel.onFinish()
		
		Self.assertEqualsI(1, action1.timesFinished)
		Self.assertEqualsI(1, action2.timesFinished)
	End Method
	
	' ------------------------------------------------------------
	' -- ParallelAction.execute
	' ------------------------------------------------------------

	Method testParallelActionExecutesAllActionsDuringExecute() { test }
		' Create test actions
		Local action1:TestAction = new TestAction
		Local action2:TestAction = new TestAction

		' Create parallel action and add test actions.
		Local parallel:ParallelAction = ParallelAction.Create()
		parallel.add(action1)
		parallel.add(action2)
		
		' Execute once
		parallel.execute(0)
		
		' Both actions should have executed once.
		Self.assertEqualsI(1, action1.timesCalled)
		Self.assertEqualsI(1, action2.timesCalled)
	End Method
	
	Method testParallelActionOnlyFinishesWhenAllActionsFinished() { test }
		' Create test actions
		Local action1:TestAction = TestAction.Create(0)
		Local action2:TestAction = TestAction.Create(1)
		
		Local parallel:ParallelAction = ParallelAction.Create()
		parallel.add(action1)
		parallel.add(action2)
		
		' Should not be finished before execution.
		Self.assertFalse(parallel.isFinished())
		
		' Execute once - this will finish action1 but not action2
		parallel.execute(0)
		Self.assertFalse(parallel.isFinished())

		' Execute again - this will finish action2
		parallel.execute(0)
		
		' Should be finished after both actions complete
		Self.assertTrue(parallel.isFinished())
	End Method
End Type

Type TestService extends GameService
End Type

Type TestAction extends BackgroundAction
	Field service:TestService { autoload_service }
	
	Field timesStarted:Int     = 0
	Field timesCalled:Int      = 0
	Field timesFinished:Int    = 0
	Field timesToRun:Int       = 0
	Field timesInitialized:Int = 0

	Method init()
		Self.timesInitialized :+ 1
	End Method

	Method onStart()
		Self.timesStarted :+ 1
	end method

	Method execute(delta:Float)
		Self.timesCalled :+ 1

		If Self.timesCalled >= Self.timesToRun Then Self.finished()
	End Method

	Method onFinish()
		Self.timesFinished :+ 1
	End Method
		
	Function Create:TestAction(timesToRun:Int)
		Local this:TestAction = New TestAction
		this.timesToRun = timesToRun
		Return this
	End Function
End Type
