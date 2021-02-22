' ------------------------------------------------------------------------------
' -- src/core/background_action.bmx
' --
' -- Wraps a piece of scriptable behaviour that needs to occur over more than a
' -- single frame.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.core
Import pangolin.events

''' <summary>
''' Run non-blocking actions.
'''
''' A background action is anything that needs to be running whilst other stuff
''' is going on without blocking anything. This could be a camera effect, moving
''' a set of entities or anything else.
''' <summary>
Type BackgroundAction Extends KernelAwareInterface Abstract

	Field _isFinished:Byte       '''< Has this action finished?
	Field _eventData:Object		 '''< Optional event data to send when action finishes.
	Field _hooks:Hooks           '''< Hooks that run at various times.


	' ------------------------------------------------------------
	' -- Shared hooks
	' ------------------------------------------------------------

	Method whenFinished(handler:EventHandler)
		Self._hooks.add("action_finished", handler)
	End Method

	''' <summary>Alias for `whenFinished` for fluent interfaces.</summary>
	Method andThen(handler:EventHandler)
		Self.whenFinished(handler)
	End Method


	' ------------------------------------------------------------
	' -- Abstract Methods
	' ------------------------------------------------------------

	Method execute(delta:Float) Abstract


	' ------------------------------------------------------------
	' -- Stub Methods
	' ------------------------------------------------------------

	''' <summary>
	''' Initialize the background action.
	''' </summary>
	Method init()

	End Method

	Method onStart()
	End Method

	''' <summary>Called when the background action has finished.</summary>
	Method onFinish()
		' Fire hooks.
		Self._hooks.sendEvent(GameEvent.CreateSimple("action_finished", Self._eventData))

		' TODO: Don't send resume process here! Send "background action finished" or something
		If Self._eventData Then
			GameEvent.fireEvent("EVENT_RESUME_PROCESS", Self, Self._eventData)
		EndIf
	End Method


	' ------------------------------------------------------------
	' -- Finishing
	' ------------------------------------------------------------

	''' <summary>Check if the action has finished executing.</summary>
	Method isFinished:Byte()
		Return Self._isFinished
	End Method

	''' <summary>Mark the action as finished.</summary>
	Method finished()
		Self._isFinished = True
	End Method


	' ------------------------------------------------------------
	' -- Event Methods
	' ------------------------------------------------------------

	''' <summary>
	''' Set the event data that will fire when the background action finishes.
	''' </summary>
	''' <param name="data">Object data to send.</param>
	Method setEventData(data:Object)
		Self._eventData = data
	End Method

	Method New()
		Self._hooks = Hooks.Create(["action_finished"])
	End Method

End Type
