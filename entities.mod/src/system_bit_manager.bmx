' ------------------------------------------------------------------------------
' -- Pangolin.Entities -- system_bit_manager.bmx
' --
' -- Keeps system bits. Each system has a unique identifier, and these are
' -- managed by this service.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.map
Import brl.reflection

Type SystemBitManager

	Global _currentBitPosition:Int      = 0
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
	Function getBitFor:Long(entitySystemType:TTypeId)

		' Check the passed in system type is a type of EntitySystem
		If False = entitySystemType.ExtendsType(SystemBitManager.getEntitySystemTypeId()) Then
			' TODO: Should throw "InvalidObjectTypeException" here
			Throw "Must extend EntitySystem"
		EndIf

		' Check if this system bit has already been added
		Local bitObject:Object = SystemBitManager._systemBits.ValueForKey(entitySystemType)
		If bitObject Then
			Return Long(bitObject.ToString())
		End If

		' Bit is not in cache, so assign a new one and return it
		Local bit:Long = 1 Shl SystemBitManager._currentBitPosition
		SystemBitManager._currentBitPosition:+ 1
		SystemBitManager._systemBits.Insert(entitySystemType, String(bit))

		Return bit

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
