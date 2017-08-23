' ------------------------------------------------------------------------------
' -- src/game_session.bmx
' -- 
' -- Represents a single session within the game engine. A generic container
' -- storing flags and other data. Highly recommended to extend this class
' -- for your own project.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.map

Type GameSession
	
	Field _data:TMap
	Field _createdAt:String
	Field _playTime:Int
	Field _currentStart:Int
	
	Method getString:String(name:String)
		Return String(Self.get(name))
	End Method
	
	Method getInt:Int(name:String)
		Return Int(String(Self.get(name)))
	End Method
	
	Method get:Object(name:String)
		Return Self._data.ValueForKey(name)
	End Method
	
	Method set(name:String, value:Object)
		Self._data.Insert(name, value)
	End Method
	
	Method start()
		Self._currentStart = MilliSecs()
	End Method
	
	Method stop()
		Self._playTime:+ (MilliSecs() - Self._currentStart)
	End Method
	
	Method New()
		Self._data = New TMap
	End Method
	
End Type
