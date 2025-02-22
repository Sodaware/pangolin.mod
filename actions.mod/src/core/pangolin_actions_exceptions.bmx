' ------------------------------------------------------------------------------
' -- src/core/pangolin_actions_exceptions.bmx
' --
' -- Custom exceptions for the actions.mod module.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2025 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

''' <summary>Base exception that the actions module will throw.</summary>
Type Pangolin_Actions_Exception Extends TBlitzException
End Type

Type Pangolin_Actions_NullActionException Extends Pangolin_Actions_Exception
	Method ToString:String()
		Return "Valid BackgroundAction object expected, Null received instead"
	End Method
End Type
