' ------------------------------------------------------------------------------
' -- src/event_handler.bmx
' -- 
' -- Wraps a function pointer in an object so it can be added to collections. No
' -- need to create these directly, they're created internally by the 
' -- EventService when event handlers are added.
' -- 
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.reflection
Import "game_event.bmx"

Type EventHandler
	
	Field _caller:Object
	Field _method:TMethod
	Field _callback:Object(event:GameEvent)

	
	' ------------------------------------------------------------
	' -- Execution
	' ------------------------------------------------------------

	''' <summary>Call the event handler for an event.</summary>
	''' <param name="event">The emitted event.</param>
	Method call:Object(event:GameEvent)
		
		If Self._caller = Null Then
			Return Self._callback(event)
		Else
			' Only send event to the method if it as an `event` parameter
			If Self._method.ArgTypes() = Null Or Self._method.ArgTypes().Length = 0 Then
				Return Self._method.Invoke(Self._caller, Null)
			Else
				Return Self._method.Invoke(Self._caller, [event])
			End If
		EndIf
		
	End Method
	

	' ------------------------------------------------------------
	' -- Debug Helpers
	' ------------------------------------------------------------
	
	Method ToString:String()
		If Self._caller And Self._method Then
			Return "<EventHandler> " + TTypeId.ForObject(Self._caller).Name() + "." + Self._method.Name()
		ElseIf Self._caller Then
			Return "<EventHandler> " + TTypeId.ForObject(Self._caller).Name()
		Else
			Return "<EventHandler> " + "callback"
		EndIf
	End Method
	
	
	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------
	
	Function Create:EventHandler(callback:Object(event:GameEvent))
		Local this:EventHandler = New EventHandler
		this._callback	= callback
		Return this
	End Function
	
	Function CreateCallback:EventHandler(caller:Object, methodName:String)
		
		Local this:EventHandler = New EventHandler
		
		this._caller = caller
		this._method = TTypeId.ForObject(caller).FindMethod(methodName)
		
		' Must be a valid method
		If this._method = Null Then Throw "Cannot create a callback for missing method: " + methodName

		Return this
		
	End Function

End Type
