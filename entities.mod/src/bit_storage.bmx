' ------------------------------------------------------------------------------
' -- src/bit_storage.bmx
' --
' -- Stores unique bits (such as service bits or type bits) in a structure that
' -- supports fast setting/getting. This was originally provided by a single
' -- `Long` variable, but that fails with > 32 services or component types.
' --
' -- This method is not as fast as a bitwise lookup, but is faster than an array
' -- or TList.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.retro
Import brl.bank

' TODO: Update this to use PeekLong/PokeLong instead of PeekByte/PokeByte?

''' <summar>
''' Stores unique bits for fast setting/getting.
'''
''' It supports storing values up to 255.
''' </summary>
Type BitStorage
	Field _bits:TBank

	Method getSize:Short()
		Return Self._bits.size() Shr 4
	End Method

	Method hasBit:Byte(identifier:Byte)
		If identifier = 0 Then Throw "oops"
		identifier :- 1

		Return (..
			Self._bits.PeekByte(identifier Shr 3) Shr (identifier Mod 8) ..
		) & %00000001
	End Method

	' TODO: THIS IS SLOW! FIX IT!!!
	' Check that this object contains all bits from `bits`. They do not need to match.
	Method containsAllBits:Byte(bits:BitStorage)
		' TODO: Peek each long and compare them using bitwise operators
		For Local i:Int = 1 To 15 * 8
			If Self.hasBit(i) <> bits.hasBit(i) Then Return False
		Next

		Return True
	End Method

	' TODO: THIS IS SLOW! FIX IT!!!
	Method isEmpty:Byte()
		For Local i:Int = 0 To Self._bits.size() - 1
			If Self._bits.peekbyte(i) Then Return False
		Next

		Return True
	End Method
	
	Method setBit:Byte(identifier:Byte)
		identifier :- 1

		Self._bits.PokeByte( ..
			identifier Shr 3, ..
			Self._bits.PeekByte(identifier Shr 3) | (1 Shl (identifier Mod 8)) ..
		)
	End Method

	Method clearBit(identifier:Byte)
		identifier :- 1

		Self._bits.PokeByte( ..
			identifier Shr 3, ..
			Self._bits.PeekByte(identifier Shr 3) & (0 Shl (identifier Mod 8)) ..
		)
	End Method

	Method resize(size:Byte)
		?bmxng
		ResizeBank(Self._bits, size_t(size))
		?Not bmxng
		ResizeBank(Self._bits, size)
		?
	End Method

	Method clearBits()
		For Local i:Int = 0 To Self._bits.size() - 1
			Self._bits.PokeByte(i, 0)
		Next
	End Method

	Method New()
		Self._bits = CreateBank(16)
	End Method
End Type
