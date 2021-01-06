' ------------------------------------------------------------------------------
' -- src/systems/delated_entity_system.bmx
' --
' -- Runs only after a set amount of time has elapsed.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------

''' <summary>
''' System that runs only after a set amount of time has elapsed.
''' </summary>
Type DelayedEntitySystem Extends EntitySystem Abstract
	Field _delay:Float              '< The number of milliseconds to wait before running.
	Field _running:Byte             '< Is the timer running?
	Field _elapsedtime:Float        '< The number of milliseconds elapsed.


	' ------------------------------------------------------------
	' -- Starting / Stopping
	' ------------------------------------------------------------

	''' <summary>Start the system and wait for a set amount of time.</summary>
	Method startDelayedRun(delayTime:Float)
		Self._delay       = delayTime
		Self._elapsedTime = 0
		Self._running     = True
	End Method

	Method stop()
		Self._running     = False
		Self._elapsedTime = 0
	End Method


	' ------------------------------------------------------------
	' -- Querying
	' ------------------------------------------------------------

	''' <summary>Is this system's timer running?</summary>
	Method isRunning:Byte()
		Return Self._running
	End Method

	Method getInitialTimeDelay:Float()
		Return Self._delay
	End Method

	Method getRemainingTimeUntilProcessing:Float()
		If Self._running = False Then Return 0

		Return Self._delay - Self._elapsedTime
	End Method


	' ------------------------------------------------------------
	' -- Processing entities
	' ------------------------------------------------------------

	''' <summary>Process a single entity.</summary>
	Method processEntity(e:Entity) Abstract

	''' <summary>Internal method to process a collection of entities.</summary>
	Method _processEntities(entities:EntityBag, acc:Float) Abstract

	''' <summary>Process all related entities and then stops the system.</summary>
	Method processEntities(entities:EntityBag)
		Self._processEntities(entities, Self._elapsedTime)
		Self.stop()
	End Method

	''' <summary>Check if this system can process entities.</summary>
	Method checkProcessing:Byte() Final
		If Not Self._running Then Return False

		Self._elapsedTime :+ Self._world.getDelta()

		Return Self._elapsedTime >= Self._delay
	End Method

End Type
