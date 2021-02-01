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
Import pangolin.events

Import "../behaviour/sprite_behaviour.bmx"


Type SpriteBehaviourService Extends GameService ..
	{ implements = "update" }

	Field _behaviours:TList = New TList

	''' <summary>
	''' Add a sprite behaviour to the list of running behaviours and
	''' call its `onStart` method.
	''' </summary>
	Method add:SpriteBehaviour(behaviour:SpriteBehaviour)
		Self._behaviours.AddLast(behaviour)
		behaviour.onStart()

		Return behaviour
	End Method

	Method remove(behaviour:SpriteBehaviour)
		Self._behaviours.remove(behaviour)
	End Method

	Method clear()
		Self._behaviours.clear()
	End Method

	Method update(delta:Float)

		If Self._behaviours.Count() = 0 Then Return

		' Run all behaviours
		For Local b:SpriteBehaviour = EachIn Self._behaviours
			b.update(delta)

			' If the behaviour is finished, call its `onFinished` method and
			' remove it from the active list.
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
