' --------------------------------------------------------------------------------
' -- src/component_schema.bmx
' --
' -- Describes the STRUCTURE of an EntityComponent.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.retro
Import brl.linkedlist
Import brl.map

Import "component_field.bmx"

''' <summary>Describes the structure of a component within the application.</summary>
Type ComponentSchema
	
	' Standard information
	Field _name:String				'''< The name of the component
	Field _description:String		'''< A brief description of the component
	Field _sourceFile:String		'''< The name of the file this component is declared in.
	
	' Internal data
	Field _isInternal:Byte          '''< Is this an internal (ie BlitzMax) component or a script component
	Field _requires:TList
	Field _internals:TList
	
	Field _fields:TMap				'''< ObjectHash of fields.
	Field _fieldsList:TList			'''< List of fields for iterating
	
	
	' --------------------------------------------------
	' -- Checking for items
	' --------------------------------------------------
	
	''' <summary>Check if this component has a property with `propertyName`.</summary>
	''' <param name="propertyName">The property to check for.</param>
	''' <return>True if the property exists, false if not.</return>
	Method hasProperty:Byte(propertyName:String)
		Return (Self._fields.ValueForKey(propertyName.ToLower()) <> Null)
	End Method
	
	Method hasRequirement:Byte(name:String)
		For Local requirement:String = EachIn Self._requires
			If requirement.ToLower() = name.ToLower() Then Return True
		Next
	End Method
		
	
	' --------------------------------------------------
	' -- General Information
	' --------------------------------------------------
	
	Method getName:String()
		Return Self._name
	End Method
	
	Method getDescription:String()
		Return Self._description
	End Method
	
	
	' --------------------------------------------------
	' -- Fields and Field Information
	' --------------------------------------------------
		
	''' <summary>Get the number of fields a schema has.</summary>
	Method countFields:Int()
		Return Self._fieldsList.Count()
	End Method
	
	Method getField:ComponentField(fieldName:String)
		Return ComponentField(Self._fields.ValueForKey(fieldName))
	End Method

	Method getFields:TList()
		Return Self._fieldsList
	End Method
	
	Method getFieldType:String(propertyName:String)
		
		Local fld:ComponentField = Self.getField(propertyName)
		
		If fld = Null Then Throw "Field ~q" + propertyName + "~q not found"
		Return fld.GetType()		
		
	End Method
	
	
	' --------------------------------------------------
	' -- Internals
	' --------------------------------------------------
	
	Method getInternals:TList()
		Return Self._internals
	End Method
	
	
	' --------------------------------------------------
	' -- Adding / Setting Information
	' --------------------------------------------------
	
	Method addField(newField:ComponentField)
		
		' Check inputs
		If newField = Null Then Return
		
		' Add to list of fields and lookup
		Self._fieldsList.AddLast(newField)
		Self._fields.Insert(Lower(newField.getName()), newField)
		
	End Method
		
	' ----- Internal stuff
	
	Method _addRequirement(name:String)
		If Self.HasRequirement(name.ToLower()) = False Then 
			Self._requires.AddLast(name.ToLower()) 
		End If
	End Method

	Method _addInternal(name:String)
		Self._internals.AddLast(name)
	End Method
	
	' TODO: Rebuild this
	Method _hasInternal:Byte(name:String)
		For Local i:String = EachIn Self._internals
			If i = name Then Return True
		Next
		Return False
	End Method
	
	Method _dump:String()
		
		Local output:String 
	
		output:+ "Internals { "
		For Local internal:String = EachIn Self._internals
			output:+ "~t" + internal + ", "		
		Next
		output :+ "}"
	
		Return output
		
	End Method
		
	
	' --------------------------------------------------
	' -- Creation / Destruction
	' --------------------------------------------------
	
	Method New()
		Self._fields		= New TMap
		Self._fieldsList	= New TList
		Self._requires		= New TList
		Self._internals		= New TList
	End Method
	
	Function Create:ComponentSchema(identifier:String, doc:String)
		Local this:ComponentSchema	= New ComponentSchema
		
		this._name 			= identifier
		this._description	= doc
		
		Return this
	End Function
	
End Type
