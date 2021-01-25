' ------------------------------------------------------------------------------
' -- Pangolin.Entities -- system_bit_manager.bmx
' --
' -- Keeps system bits. Each system has a unique identifier, and these are
' -- managed by this object.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2020 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type SystemBitManager

	Global _currentBitPosition:Byte     = 1
	Global _systemBits:TMap             = New TMap
	Global _entitySystemTypeId:TTypeId  = Null


	' ------------------------------------------------------------
	' -- Generating bits
	' ------------------------------------------------------------

	''' <summary>
	''' Fetch a unique bit identifier for an entity system type.
	''' </summary>
	''' <param name="entitySystemType">The TTypeId for the EntitySystem to add.</param>
	''' <returns>Unique bit for this type.</returns>
	Function getBitFor:Byte(entitySystemType:TTypeId)
		' Check the passed in system type is a type of EntitySystem.
		If False = entitySystemType.ExtendsType(SystemBitManager.getEntitySystemTypeId()) Then
			Throw InvalidSystemTypeException.Create(entitySystemType)
		EndIf

		' TODO: Convert this to ByteMap or something.
		Local bitObject:Object = SystemBitManager._systemBits.ValueForKey(entitySystemType)
		If bitObject Then
			Return Byte(bitObject.ToString())
		End If

		' Bit is not in cache, so assign a new one and return it
		SystemBitManager._currentBitPosition :+ 1
		SystemBitManager._systemBits.Insert(entitySystemType, String(SystemBitManager._currentBitPosition - 1))

		Return SystemBitManager._currentBitPosition - 1
	End Function


	' ------------------------------------------------------------
	' -- Internal Helpers
	' ------------------------------------------------------------

	''' <summary>Get the TTypeId for `EntitySystem`.</summary>
	Function getEntitySystemTypeId:TTypeId()
		If SystemBitManager._entitySystemTypeId = Null Then
			SystemBitManager._entitySystemTypeId = TTypeId.ForName("EntitySystem")
		End If

		Return SystemBitManager._entitySystemTypeId
	End Function

End Type
