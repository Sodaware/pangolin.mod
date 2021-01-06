' ------------------------------------------------------------------------------
' -- src/systems/delated_entity_processing_system.bmx
' --
' -- Processes entities after a set amount of time has elapsed.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------

''' <summary>
''' Base system for processing entities after a set amount of time has elapsed.
'''
''' Will only call the "_processEntities" method once enough time has passed. The
''' total time that elapsed can get retrieved with `getElapsedTime`.
''' </summary>
''' <seealso cref="DelayedEntitySystem">Base delay system.</seealso>
Type DelayedEntityProcessingSystem Extends DelayedEntitySystem Abstract
	Field _accumulatedDelta:Float

	''' <summary>Get the total amount of milliseconds that passed.</summary>
	Method getElapsedTime:Float()
		Return Self._accumulatedDelta
	End Method

	Method _processEntities(entities:EntityBag, accumulatedDelta:Float) Final
		Self._accumulatedDelta = accumulatedDelta

		For Local e:Entity = EachIn entities
			Self.processEntity(e)
		Next
	End Method

End Type
