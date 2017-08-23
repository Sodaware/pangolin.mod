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


Type ComponentField

	Const PROTECTIONLEVEL_PRIVATE:Byte   = 1
	Const PROTECTIONLEVEL_PROTECTED:Byte = 2
	Const PROTECTIONLEVEL_PUBLIC:Byte    = 3
	
	'  About
	Field _name:String              '''< The name of the field
	Field _description:String       '''< Optional description of the field
	
	' Structure
	Field _defaultValue:String      '''< The default value for the field
	Field _protectionLevel:Byte     '''< The protection level for this type.
	Field _dataType:String          '''< The name of the data type for this field (e.g. int, bool, string)
	
	
	' ------------------------------------------------------------
	' -- Getters & Setters
	' ------------------------------------------------------------
	
	''' <summary>Sets the name of the component field.</summary>
	''' <param name="componentName">The name of the component field.</param>
	Method setName:ComponentField(componentName:String)
		Self._name = componentName
		Return Self
	End Method
	
	''' <summary>Sets the description of the ComponentField object.</summary>
	''' <param name="componentDescription">The description of the component field</param>
	Method setDescription:ComponentField(componentDescription:String)
		Self._description = componentDescription
		Return Self
	End Method
	
	Method setDefaultValue:ComponentField(defaultValue:String)
		Self._defaultValue = defaultValue
		Return Self
	End Method
	
	Method setDataType:ComponentField(dataType:String)
		Self._dataType = dataType
		Return Self
	End Method
	
	Method setProtectionLevel:ComponentField(protectionLevel:String)
		
		Select Upper(protectionLevel)
			Case "PRIVATE";		Self._protectionLevel = PROTECTIONLEVEL_PRIVATE
			Case "PROTECTED";	Self._protectionLevel = PROTECTIONLEVEL_PROTECTED
			Case "PUBLIC";		Self._protectionLevel = PROTECTIONLEVEL_PUBLIC
		End Select
		
		Return Self
		
	End Method
	
	Method getType:String()
		Return Self._dataType
	End Method
	
	Method getName:String()
		Return Self._name
	End Method

	Method getDescription:String()
		Return Self._description
	End Method
	
	Method getDefaultValue:String()
		Return Self._defaultValue
	End Method
	

	' ------------------------------------------------------------
	' -- Creation & Destruction
	' ------------------------------------------------------------

	Method New()
		Self._protectionLevel = PROTECTIONLEVEL_PRIVATE
	End Method
	
End Type
