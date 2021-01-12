' ------------------------------------------------------------------------------
' -- src/component_type.bmx
' --
' -- The ComponentType object is used for mapping Components to Entities. This
' -- should not be used outside of the module.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

''' <summary>
''' The ComponentType object is used for mapping Components to Entities.
'''
''' This relationship is handled internally by the module, so instances of this
''' type should not be created elsewhere.
''' </summary>
Type ComponentType

	''' <summary>The next unique Type bit to be assigned.</summary>
	Global nextBit:Byte  = 1

	''' <summary>The next unique ID for a component type.</summary>
	Global nextId:Int    = 0

	Field _name:String          '''< The BlitzMax type name for this component type.
	Field _bit:Byte             '''< The ComponentType's unique bit.
	Field _id:Int               '''< The ComponentType's unique ID.


	' ------------------------------------------------------------
	' -- Querying
	' ------------------------------------------------------------

	''' <summary>Get the name for this component type.</summary>
	Method getName:String()
		Return Self._name
	End Method

	''' <summary>Get the unique bit for this component type.</summary>
	Method getBit:Byte()
		Return Self._bit
	End Method

	''' <summary>Get the unique id number for this component type.</summary>
	Method getId:Int()
		Return Self._id
	End Method


	' ------------------------------------------------------------
	' -- Getting Bits/Identifiers
	' ------------------------------------------------------------

	''' <summary>Get the next available unique bit.</summary>
	Function _getNextBit:Int()
		ComponentType.nextBit :+ 1

		Return ComponentType.nextBit - 1
	End Function

	''' <summary>Get the next available unique identifier.</summary>
	Function _getNextId:Int()
		ComponentType.nextId :+ 1

		Return ComponentType.nextId - 1
	End Function


	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------

	''' <summary>Create a new ComponentType instance.</summary>
	Method New()
		Self._id  = ComponentType._getNextId()
		Self._bit = ComponentType._getNextBit()
	End Method

End Type
