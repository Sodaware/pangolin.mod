' ------------------------------------------------------------------------------
' -- src/game_session_service.bmx
' --
' -- Simple service for working with game sessions. Stores a single session
' -- and adds some quick access to it.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2018 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.core

Import "game_session.bmx"

Type GameSessionService Extends GameService

	Field _session:GameSession


	' ------------------------------------------------------------
	' -- Getting Info
	' ------------------------------------------------------------

	''' <summary>Get the current game session.</summary>
	Method getSession:GameSession()
		Return Self._session
	End Method

	''' <summary>Check if the current session has a parameter with a value.</summary>
	''' <param name="name">Name of the parameter to search for.</param>
	''' <returns>True if the paramter has a value, false if not.</returns>
	Method hasValue:Byte(name:String)
		Return Null <> Self._session.get(name)
	End Method

	''' <summary>Check if the current session a flag set to true.</summary>
	''' <param name="name">Name of the parameter to check.</param>
	''' <returns>True if the paramter is set (and equal to true). False otherwise.</returns>
	Method hasFlag:Byte(name:String)
		Return True = Self.getInt(name)
	End Method

	''' <summary>Get a string value from the current session.</summary>
	''' <param name="name">The parameter to get.</param>
	Method getString:String(name:String)
		Return Self._session.getString(name)
	End Method

	''' <summary>Get an integer value from the current session.</summary>
	''' <param name="name">The parameter to get.</param>
	Method getInt:Int(name:String)
		Return Self._session.getInt(name)
	End Method

	''' <summary>Get an object value from the current session.</summary>
	''' <param name="name">The parameter to get.</param>
	Method get:Object(name:String)
		Return Self._session.get(name)
	End Method


	' ------------------------------------------------------------
	' -- Setting Info
	' ------------------------------------------------------------

	''' <summary>Set a parameter in the current session to an object or string value.</summary>
	''' <param name="name">The parameter to set.</param>
	Method set(name:string, value:Object)
		Self._session.set(name, value)
	End Method

	''' <summary>Set a parameter in the current session to an integer value.</summary>
	''' <param name="name">The parameter to set.</param>
	Method setInt(name:String, value:Int)
		Self._session.set(name, String(value))
	End Method

	''' <summary>Set a flag value to either true or false.</summary>
	''' <param name="name">The parameter to set.</param>
	Method setFlag(name:String, value:Byte = True)
		Self.setInt(name, value)
	End Method

	''' <summary>Remove a flag or parameter from the current session.</summary>
	''' <param name="name">The parameter to remove.</param>
	Method unsetFlag(name:String)
		Self.getSession()._data.Remove(name)
	End Method

	''' <summary>
	''' Increase a parameter by a value. If the parameter was previously
	''' unset OR a none-integer value, it will be treated as 0.
	''' </summary>
	''' <param name="name">The parameter to increase.</param>
	''' <param name="increaseBy">The amount to increase by. Defaults to 1.</param>
	Method increaseField(name:String, increaseBy:Int = 1)
		Self.setInt(name, Self.getInt(name) + increaseBy)
	End Method

	''' <summary>
	''' Decrease a parameter by a value. If the parameter was previously
	''' unset OR a none-integer value, it will be treated as 0.
	''' </summary>
	''' <param name="name">The parameter to decrease.</param>
	''' <param name="decreaseBy">The amount to decrease by. Defaults to 1.</param>
	Method decreaseField(name:String, decreaseBy:Int = 1)
		Self.setInt(name, Self.getInt(name) - decreaseBy)
	End Method


	' ------------------------------------------------------------
	' -- Utility Functions
	' ------------------------------------------------------------

	''' <summary>Copy a session value from one parameter to another.</summary>
	Method copy(fromName:String, toName:String)
		Self._session.set(toName, Self.get(fromName))
	End Method

	''' <summary>
	''' Reset the current session. Destroys the session object and creates
	''' a new one.
	''' </summary>
	Method reset()
		Self._session = Null
		Self._session = New GameSession
		GCCollect()
	End Method


	' ------------------------------------------------------------
	' -- Construction
	' ------------------------------------------------------------

	Method New()
		Self._session = New GameSession
	End Method

End Type
