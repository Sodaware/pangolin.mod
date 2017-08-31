' ------------------------------------------------------------------------------
' -- src/events_service.bmx
' -- 
' -- Main events service. Hooks into BlitzMax events and manages event handler
' -- mappings.
' -- 
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.reflection
Import pangolin.core
Import sodaware.ObjectBag

Import "game_event.bmx"
Import "event_handler.bmx"
Import "game_event_mapper.bmx"


Type EventService Extends GameService
	
	''' <summary>Map of eventName => ObjectBag of handlers
	Field _handlers:TMap = New TMap
	
	
	' ------------------------------------------------------------
	' -- Adding / Removing Handlers
	' ------------------------------------------------------------
	
	Method addHandler:Int(eventName:String, callback:Object(event:GameEvent))
		
		' Create new handler to wrap the callback.
		Local handler:EventHandler = EventHandler.Create(callback)
		
		' Add to collection of handlers
		Local bag:ObjectBag	= ObjectBag(Self._handlers.ValueForKey(eventName))
		If bag = Null Then
			bag = New ObjectBag
			Self._handlers.Insert(eventName, bag)
		End If
		
		bag.add(handler)
		
	End Method
	
	''' <summary>
	''' Add a callback to the event service. A callback consists of an 
	''' object and a method name. When the event is fired, `methodName`
	''' will be called on the `caller` object.
	''' <summary>
	''' <param name="eventName">The event this callback will listen for.</param>
	Method addCallback(eventName:String, caller:Object, methodName:String)
			
		' Local eventIdentifier:Int = GameEventMapper.getEventId(eventName)

		' Create new handler
		' [todo] - Check the handler actually has an Event argument
		Local handler:EventHandler = EventHandler.CreateCallback(caller, methodName)
		
		' Add to collection of handlers
		Local eventHandlers:ObjectBag = ObjectBag(Self._handlers.ValueForKey(eventName))
		If eventHandlers = Null Then
			eventHandlers = New ObjectBag
			Self._handlers.Insert(eventName, eventHandlers)
		End If
		
		' Add this handler to the 
		eventHandlers.add(handler)
		
	End Method
	
	Method removeCallback(eventName:String, caller:Object, methodName:String)
		
		' Get the event bag
		Local bag:ObjectBag = ObjectBag(Self._handlers.ValueForKey(eventName))
		If bag = Null Then Return
		
		' Find thie object / method
		For Local handler:EventHandler = EachIn bag
			If handler._caller = caller And handler._method.Name() = methodName Then
				bag.removeObject(handler)
				Return
			EndIf
		Next
		
	End Method
	
	''' <summary>Remove all handlers for a specific event.<summary>
	Method removeEventHandlers(eventName:String)
		
		' Get all handlers for this event
		Local handlers:ObjectBag = ObjectBag(Self._handlers.ValueForKey(eventName))
		If handlers = Null Then Return
		
		' Clear each handler object
		For Local handler:EventHandler = EachIn handlers
			handler = Null
		Next
		
		' Remove from the list and then delete the handler list
		Self._handlers.Remove(eventName)
		handlers = Null
		
	End Method
	
    
	' ------------------------------------------------------------
	' -- Service setup / shutdown
	' ------------------------------------------------------------
	
	''' <summary>
	''' Called when kernel is started. Hooks up to BlitzMax event emitter.
	''' </summary>
	Method onResume()
		AddHook(EmitEventHook, EventService._handleEvents, Self, 1)
	End Method
	
	''' <summary>Free event hook when service stops.</summary>
	Method onSuspend()
		RemoveHook(EmitEventHook, EventService._handleEvents, Self)		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Internal helpers
	' ------------------------------------------------------------
	
	''' <summary>
	''' Called when an event is triggered.
	''' </summary>
	Function _handleEvents:Object(id:Int, eventData:Object, context:Object)
		
		' Only handle emitted events and events with data
        if id <> EmitEventHook then return eventData
        If GameEvent(EventData) = Null Then Return eventData
        
		' Get the event
		Local event:GameEvent		= GameEvent(eventData)
		Local service:EventService	= EventService(context)
        
        ' Get handlers
		Local eventName:String		= GameEventMapper.getEventName(event.id)
		Local handlers:ObjectBag	= ObjectBag(service._handlers.ValueForKey(eventName))
		
		If handlers = Null Then Return eventData
		
		For Local handler:EventHandler = EachIn handlers
			handler.call(event)
		Next
		
	End Function
	
	
	' ------------------------------------------------------------
	' -- Debug Helpers
	' ------------------------------------------------------------
	
	''' Dump all events to the event log
	Method dumpEvents()
		
	End Method
	
	Method ToString:String()
		Return "<Pangolin.Events.EventService>"
	End Method
	
End Type
