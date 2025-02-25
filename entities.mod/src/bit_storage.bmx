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

Import brl.bank

''' <summar>
''' Stores unique bits for fast setting/getting.
'''
''' Each component is assigned a unique bit at runtime. This bit is used by
''' systems to quickly check if they need to process an entity.
'''
''' By default BitStorage supports storing values up to 255, but it can be
''' resized if needed.
''' </summary>
Type BitStorage
	Field _bits:TBank

	' ------------------------------------------------------------
	' -- Size Info
	' ------------------------------------------------------------

	''' <summary>Get the site of the internal struture in bits.</summary>
	''' <return>The size.</return>
	Method getSize:Short()
		Return Self._bits.size() Shl 3
	End Method

	''' <summary>Check if all bits are set to 0.</summary>
	Method isEmpty:Byte()
		For Local i:Int = 0 To Self._bits.size() - 1
			If Self._bits.peekByte(i) Then Return False
		Next

		Return True
	End Method

	' ------------------------------------------------------------
	' -- Checking Bits
	' ------------------------------------------------------------

	''' <summary>Check if this storage contains a specific bit identifier.</summary>
	''' <param name="identifier">The bit identifier to check. Must be greater than 1.</param>
	''' <return>True if storage contains the identifier, false if not.</return>
	Method hasBit:Byte(identifier:Byte)
		If identifier = 0 Then Throw "oops"
		identifier :- 1

		Return (..
			Self._bits.PeekByte(identifier Shr 3) Shr (identifier Mod 8) ..
		) & %00000001
	End Method

	''' <summary>
	''' Check that this object contains all bits from `bits`.
	'''
	''' Only checks that it contains all identifiers from the target storage, it does not
	''' check if both storages are identical.
	''' <summary>
	''' <param name="bits">The storage to compare with.</param>
	''' <return>True if this storage contains all bits from the target. False if not.</return>
	Method containsAllBits:Byte(bits:BitStorage)
		Local subject:Byte
		Local compare:Byte

		For Local i:Int = 0 To Self._bits.size() - 1
			subject = Self._bits.PeekByte(i)
			compare = bits._bits.PeekByte(i)

			If subject & compare <> compare Then Return False
		Next

		Return True
	End Method

	' ------------------------------------------------------------
	' -- Setting / Unsetting Bits
	' ------------------------------------------------------------

	''' <summary>Set an identifier's bit to 1.</summary>
	''' <param name="identifier">The identifier to set. Must be greater than 1.</param>
	Method setBit:Byte(identifier:Byte)
		identifier :- 1

		Self._bits.PokeByte( ..
			identifier Shr 3, ..
			Self._bits.PeekByte(identifier Shr 3) | (1 Shl (identifier Mod 8)) ..
		)
	End Method

	''' <summary>Clear an identifier's bit.</summary>
	''' <param name="identifier">The identifier to clear. Must be greater than 1.</param>
	Method clearBit(identifier:Byte)
		identifier :- 1

		Self._bits.PokeByte( ..
			identifier Shr 3, ..
			Self._bits.PeekByte(identifier Shr 3) & ~(1 Shl (identifier Mod 8)) ..
		)
	End Method

	''' <summary>Clear all identifier bits.</summary>
	Method clearBits()
		For Local i:Int = 0 To Self._bits.size() - 1
			Self._bits.PokeByte(i, 0)
		Next
	End Method

	' ------------------------------------------------------------
	' -- Resizing
	' ------------------------------------------------------------

	''' <summary>Resize the BitStorage.</summary>
	''' <param name="size">The new size in bytes.</param>
	Method resize(size:Byte)
		?bmxng
		ResizeBank(Self._bits, size_t(size))
		?Not bmxng
		ResizeBank(Self._bits, size)
		?
	End Method

	' ------------------------------------------------------------
	' -- Construction
	' ------------------------------------------------------------

	Method New()
		Self._bits = CreateBank(16)
		Self.clearBits()
	End Method
End Type
