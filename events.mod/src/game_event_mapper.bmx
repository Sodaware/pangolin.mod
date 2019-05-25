' ------------------------------------------------------------------------------
' -- src/game_event_mapper.bmx
' -- 
' -- Keeps a map of event name => event id. Automatically assigns event id's to
' -- event names.
' -- 
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.map
Import brl.event

Type GameEventMapper

	' ------------------------------------------------------------
	' -- Getting event information
	' ------------------------------------------------------------

	''' <summary>Gets the name of an event id.</summary>
	''' <param name="id">The event ID to lookup.</param>
	''' <return>Event name, or an empty string if not found.</return>
	Function getEventName:String(id:Int)
		
		' Create new map
		If _GameEventMapper_eventIdMap = Null Then
			Return ""
		End If

		Return String(_GameEventMapper_eventNameMap.ValueForKey(String(id)))

	End Function

	''' <summary>
	''' Get the ID for an event name. If no ID found, will allocate one.
	''' </summary>
	''' <param name="eventName">The event name to lookup.</param>
	''' <return>ID for this event name.</return>
	Function getEventId:Int(eventName:String)
		
		' Create new map
		If _GameEventMapper_eventIdMap = Null Then
			_GameEventMapper_eventIdMap = New TMap
			_GameEventMapper_eventNameMap = New TMap
		End If

		' Check for map
		Local id:Int = Int(String(_GameEventMapper_eventIdMap.ValueForKey(eventName)))
		If id = 0 Then
			id = AllocUserEventId(eventName)
			_GameEventMapper_eventIdMap.Insert(eventName, String(id))
			_GameEventMapper_eventNameMap.insert(String(id), eventName)
		End If

		Return id

	End Function

End Type


' ------------------------------------------------------------
' -- Singleton Internals
' ------------------------------------------------------------

' These aren separate from the Type so that they can be marked
' as private

Private

Global _GameEventMapper_eventIdMap:TMap
Global _GameEventMapper_eventNameMap:TMap
