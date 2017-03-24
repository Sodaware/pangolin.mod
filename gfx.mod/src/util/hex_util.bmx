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


Function HexToRGB(hexValue:String, r:int var, g:int var, b:int var)
    
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
	DebugLog(hexValue)
	If Not(hexValue) Or hexValue.length <> 6 Then hexValue = "FFFFFF"
	
	Local red:Int	= HexToInt(Mid(hexValue, 1, 2))
	Local green:Int	= HexToInt(Mid(hexValue, 3, 2))
	Local blue:Int	= HexToInt(Mid(hexValue, 5, 2))
	
	SetColor red, green, blue
	
End Function


''' <summary>Converts a hex value to an integer value.</summary>
''' <param name="hexValue">The hex value to convert.</param>
''' <returns>Integer value.</returns>
''' <subsystem>Blitz.Basic</subsystem>
Function HexToInt:Int(hexValue$)
	
	' Check for empty strings
	If hexValue = "" Then Return 0
	If hexValue.StartsWith("#") Then hexValue = Mid(hexValue, 2)
	
	hexValue = hexValue.ToUpper()
	
	Local hexChar$
	Local hexDigit%
	Local strPos% 		= 1
	Local strLen% 		= hexValue.Length
	Local integerValue% = 0
	
	Repeat
		
		' Get next character
		hexChar		= Mid$(hexValue$, strPos, 1)
		
		' Check the character is valid
		If Instr(VALID_HEX_CHARS, hexChar) < 1 Then 
			hexDigit = 0
		Else
			hexDigit = VALID_HEX_CHARS.Find(hexChar)
		EndIf
		
		integerValue = (integerValue Shl 4) + hexDigit
		
		strPos = strPos + 1
		
	Until strPos > strLen
	
	Return integerValue
	
End Function
