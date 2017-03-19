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


Type DelayedEntitySystem Extends EntitySystem Abstract
	
	Field _delay:Int
	Field _running:Short
	Field _acc:Int
	
	Method processEntity(e:Entity) Abstract
	
	Method processEntities(entities:ObjectBag)
		Self._processEntities(entities, Self._acc)
		Self.stop()
	End Method
	
	Method _processEntities(entities:ObjectBag, acc:Float) Abstract
	
	Method checkProcessing:Short() Final
		
		If Self._running Then
			Self._acc = Self._acc + Self._world.getDelta()
			
			If Self._acc >= Self._delay Then
				Return True
			End If
		End If
		
		Return False
		
	End Method
	
	Method startDelayedRun(newDelay:Int)
		Self._delay 	= newDelay
		Self._acc		= 0
		Self._running	= True
	End Method
	
	Method getInitialTimeDelay:Int()
		Return Self._delay
	End Method
	
	Method getRemainingTimeUntilProcessing:Int()
		
		If Self._running Then
			Return Self._delay - Self._acc
		End If
		Return 0
		
	End Method
	
	Method isRunning:Short()
		Return Self._running
	End Method
	
	Method stop()
		Self._running	= False
		Self._acc		= 0
	End Method
	
End Type
