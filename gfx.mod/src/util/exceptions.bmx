' ------------------------------------------------------------------------------
' -- src/util/exceptions.bmx
' --
' -- Custom exceptions for the gfx.mod module.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2025 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

''' <summary>Base exception that GFX module will throw.</summary>
Type Pangolin_Gfx_Exception Extends TBlitzException
End Type

Type Pangolin_Gfx_InvalidEasingFunctionException Extends Pangolin_Gfx_Exception
	Field _easingType:Int

	Method ToString:String()
		Return "Invalid easing function: " + Self._easingType
	End Method

	Function Create:Pangolin_Gfx_InvalidEasingFunctionException(easingType:Int)
		Local exception:Pangolin_Gfx_InvalidEasingFunctionException = New Pangolin_Gfx_InvalidEasingFunctionException
		exception._easingType = easingType
		Return exception
	End Function
End Type
