' ------------------------------------------------------------------------------
' -- src/util/hex_util.bmx
' --
' -- Utility functions for working with hexadecimal colurs. Can convert to and
' -- from a hex string.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.retro
Import brl.max2d

Const VALID_HEX_CHARS$	= "0123456789ABCDEF"


Function HexToRGB(hexValue:String, r:Byte var, g:Byte var, b:Byte var)

	' Strip off first "#" if present
	If hexValue.StartsWith("#") Then hexValue = Mid(hexValue, 2)
	If Not(hexValue) Or hexValue.length <> 6 Then hexValue = "FFFFFF"

	r = HexToInt(Mid(hexValue, 1, 2))
	g = HexToInt(Mid(hexValue, 3, 2))
	b = HexToInt(Mid(hexValue, 5, 2))

End Function

''' <summary>A version of SetColor that takes a hex value instead.</summary>
''' <param name="hexValue">The 6 character hex value to use.</param>
Function SetColorHex(hexValue:String)
	' Strip off first "#" if present
	If hexValue.StartsWith("#") Then hexValue = Mid(hexValue, 2)
	If Not(hexValue) Or hexValue.length <> 6 Then hexValue = "FFFFFF"

	Local red:Int	= HexToInt(Mid(hexValue, 1, 2))
	Local green:Int	= HexToInt(Mid(hexValue, 3, 2))
	Local blue:Int	= HexToInt(Mid(hexValue, 5, 2))

	SetColor red, green, blue
End Function


''' <summary>Converts a hex value to an integer value.</summary>
''' <param name="hexValue">The hex value to convert.</param>
''' <return>Integer equivelant of the hex value.</return>
Function HexToInt:Int(hexValue:String)

	' Check for empty strings and remove a leading "#" symbol.
	If hexValue = "" Then Return 0
	If hexValue.StartsWith("#") Then hexValue = Mid(hexValue, 2)

	hexValue = hexValue.ToUpper()

	Local hexChar:String
	Local hexDigit:Byte
	Local strPos:Int       = 1
	Local strLen:Int       = hexValue.Length
	Local integerValue:Int = 0

	Repeat
		' Get next character.
		hexChar = Mid(hexValue, strPos, 1)

		' Check the character is valid
		If Instr(VALID_HEX_CHARS, hexChar) < 1 Then
			hexDigit = 0
		Else
			hexDigit = VALID_HEX_CHARS.Find(hexChar)
		EndIf

		' Add to the final value and move to next char.
		integerValue = (integerValue Shl 4) + hexDigit
		strPos :+ 1

	Until strPos > strLen

	Return integerValue

End Function
