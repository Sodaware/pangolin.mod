' ------------------------------------------------------------------------------
' -- src/game_event.bmx
' -- 
' -- Represents a single event. Extends the BlitzMax event system and adds
' -- support for named events rather than constants.
' -- 
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.event
Import brl.map

Import "game_event_mapper.bmx"

Type GameEvent extends TEvent

	Field name:String

	Function CreateEvent:GameEvent(eventName:String, sender:Object = Null, data:Object = Null)
		
		Local this:GameEvent = New GameEvent
		this.source	= sender
		this.id 	= GameEventMapper.getEventId(eventName)
		this.extra 	= data
		this.name   = eventName

		Return this

	End Function

	Function fireEvent:GameEvent(eventName:String, sender:Object = Null, data:Object = Null)
		Local this:GameEvent = GameEvent.CreateEvent(eventName, sender, data)
		this.emit()
		Return this
	End Function

End Type
