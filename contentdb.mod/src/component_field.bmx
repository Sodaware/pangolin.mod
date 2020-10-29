' ------------------------------------------------------------------------------
' -- src/component_field.bmx
' --
' -- Represents the layout of a field within a component schema. Does not
' -- contain its data.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.retro

''' <summary>Represents a field within a component schema.</summary>
Type ComponentField

	Const PROTECTIONLEVEL_PRIVATE:Byte   = 1
	Const PROTECTIONLEVEL_PROTECTED:Byte = 2
	Const PROTECTIONLEVEL_PUBLIC:Byte    = 3

	'  About.
	Field _name:String              '''< The name of the field.
	Field _description:String       '''< Optional description of the field.

	' Structure.
	Field _defaultValue:String      '''< The default value for the field.
	Field _protectionLevel:Byte     '''< The protection level for this type (e.g. public or private) .
	Field _dataType:String          '''< The name of the data type for this field (e.g. int, bool, string).


	' ------------------------------------------------------------
	' -- Configuring
	' ------------------------------------------------------------

	''' <summary>Set the name of the field.</summary>
	''' <param name="componentName">The name of the component field.</param>
	Method setName:ComponentField(componentName:String)
		Self._name = componentName

		Return Self
	End Method

	''' <summary>Set the description of the field.</summary>
	''' <param name="componentDescription">The description of the field.</param>
	Method setDescription:ComponentField(componentDescription:String)
		Self._description = componentDescription

		Return Self
	End Method

	''' <summary>Set the default value of the field.</summary>
	''' <param name="defaultValue">The default value for the field.</param>
	Method setDefaultValue:ComponentField(defaultValue:String)
		Self._defaultValue = defaultValue

		Return Self
	End Method

	''' <summary>Set the data type of the field.</summary>
	''' <param name="dataType">The data type name.</param>
	Method setDataType:ComponentField(dataType:String)
		Self._dataType = dataType

		Return Self
	End Method

	''' <summary>Set the protection level for the field.</summary>
	''' <param name="protectionLevel">Either PUBLIC, PRIVATE OR PROTECTED.</param>
	Method setProtectionLevel:ComponentField(protectionLevel:String)
		Select protectionLevel.ToUpper()
			Case "PRIVATE";		Self._protectionLevel = PROTECTIONLEVEL_PRIVATE
			Case "PROTECTED";	Self._protectionLevel = PROTECTIONLEVEL_PROTECTED
			Case "PUBLIC";		Self._protectionLevel = PROTECTIONLEVEL_PUBLIC
		End Select

		Return Self
	End Method


	' ------------------------------------------------------------
	' -- Getting Information
	' ------------------------------------------------------------

	''' <summary>Get the data type of the field.</summary>
	Method getName:String()
		Return Self._name
	End Method

	''' <summary>Get the description of the field. Can be empty.</summary>
	Method getDescription:String()
		Return Self._description
	End Method

	''' <summary>Get the default value of the field.</summary>
	Method getDefaultValue:String()
		Return Self._defaultValue
	End Method

	''' <summary>Get the data type of the field.</summary>
	Method getType:String()
		Return Self._dataType
	End Method

	''' <summary>Get the protection level of the field.</summary>
	''' <return>Either PROTECTIONLEVEL_PUBLIC, PROTECTIONLEVEL_PRIVATE or PROTECTIONLEVEL_PROTECTED.</return>
	Method getProtectionLevel:Byte()
		Return Self._protectionLevel
	End Method


	' ------------------------------------------------------------
	' -- Creation & Destruction
	' ------------------------------------------------------------

	Method New()
		Self._protectionLevel = PROTECTIONLEVEL_PRIVATE
	End Method

End Type
