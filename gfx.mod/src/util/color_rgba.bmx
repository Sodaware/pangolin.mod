' ------------------------------------------------------------------------------
' -- src/util/color_rgba.bmx
' --
' -- Represents a 2D colour with alpha values.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "hex_util.bmx"

Type ColorRgba
	Field red:Byte    = 0
	Field green:Byte  = 0
	Field blue:Byte   = 0
	Field alpha:Float = 1


	' ------------------------------------------------------------
	' -- Getting / Setting Information
	' ------------------------------------------------------------

	Method loadFromHexString:ColorRgba(color:String)
		HexToRGB(color, Self.red, Self.green, Self.blue)

		Return Self
	End Method

	Method ToString:String()
		Return "ColorRgba[" + Self.red + ", " + Self.green + ", " + Self.blue + "]"
	End Method


	' ------------------------------------------------------------
	' -- Construction / Destruction
	' ------------------------------------------------------------

	Function Create:ColorRgba(red:Byte, green:Byte, blue:Byte, alpha:Float = 1.0)
		Local this:ColorRgba = New ColorRgba

		this.red   = red
		this.green = green
		this.blue  = blue
		this.alpha = alpha

		Return this
	End Function

End Type
