' ------------------------------------------------------------------------------
' -- src/services/sprite_behaviour_service.bmx
' --
' -- Handles custom sprite behaviour. Allows sprite behaviour to be automated
' -- without coding individual state machines.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.core

Import "../behaviour/sprite_behaviour.bmx"


Type SpriteBehaviourService Extends GameService .. 
	{ implements = "update" }
	
	Field _behaviours:TList = New TList
	
	Method add(behaviour:SpriteBehaviour)
		Self._behaviours.AddLast(behaviour)
		behaviour.onStart()
	End Method
	
	Method update(delta:Float)
		
		If Self._behaviours.Count() = 0 Then Return
	
		For Local b:SpriteBehaviour = EachIn Self._behaviours
			b.update(delta)
			
			If b.isFinished() Then
				b.onFinish()
				Self._behaviours.Remove(b)
			EndIf
		Next
		
	End Method
	
	Method init()
		Super.init()
		Self._behaviours = New TList
	End Method
	
End Type
