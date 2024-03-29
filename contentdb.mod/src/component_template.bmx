' ------------------------------------------------------------------------------
' -- component_template.bmx
' --
' -- Used to define what a single component will look like. Maps onto types
' -- that extend EntityComponent.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------

SuperStrict

Import brl.map
Import "component_schema.bmx"

''' <summary>A template for a single component within an EntityTemplate.</summary>
Type ComponentTemplate

	Field _fieldValues:TMap					'''< Map of fieldName => fieldValue.
	Field _fieldCount:Int					'''< Number of SET fields

	Field _schema:ComponentSchema			'''< The base schema of this template.


	' --------------------------------------------------
	' -- API Methods
	' --------------------------------------------------

	Method getSchemaName:String()
		Return Self._schema.GetName()
	End Method

	Method getSchemaIdentifier:String()
		Return Self.getSchemaName().ToLower()
	End Method

	Method getSchema:ComponentSchema()
		Return Self._schema
	End Method

	Method getRawField:Object(fieldName:String)
		Return Self._fieldValues.ValueForKey(fieldName)
	End Method

	Method getFieldValue:String(fieldName:String)
		Return String(Self._fieldValues.ValueForKey(fieldName))
	End Method

	Method isFieldSet:Byte(fieldName:String)
		Return (Self._fieldValues.ValueForKey(fieldName) <> Null)
	End Method

	Method countFields:Int()
		Return Self._fieldCount
	End Method

	Method schemaHasInternal:Byte(fieldName:String)
		Return Self._schema.isFieldInternal(fieldName)
	End Method


	' --------------------------------------------------
	' -- Copying from other objects
	' --------------------------------------------------

	Method copyFromTemplate(template:ComponentTemplate)
		If template = Null Then Return
		If template.countFields() = 0 Then Return

		' Iterate through template schema fields, copying them to this template
		For Local fieldName:String = EachIn template._fieldValues.Keys()
			If Not(Self.isFieldSet(fieldName)) Then
				Self._setFieldValue(fieldName, template.GetFieldValue(fieldName))
			EndIf
		Next
	End Method

	''' <summary>Copy the default field values from a schema to a component template.</summary>
	Method copyFromSchema(schema:ComponentSchema)
		If schema = Null Then Return
		If schema.CountFields() = 0 Then Return

		' Iterate through component schema fields, checking to see if they've been set in this template.
		For Local fld:ComponentField = EachIn schema.getFields()
			If Self.isFieldSet(fld.getName()) = False Then
				Self._setFieldValue(fld.getName(), fld.getDefaultValue())
			End If
		Next
	End Method

	Method clone:ComponentTemplate()
		Return Self.copy()
	End Method

	Method copy:ComponentTemplate()
		Local this:ComponentTemplate	= ComponentTemplate.Create()

		this._schema      = Self._schema
		this._fieldValues = Self._fieldValues.Copy()
		this._fieldCount  = Self._fieldCount

		Return this
	End Method


	' --------------------------------------------------
	' -- Internal API
	' --------------------------------------------------

	Method _setFieldValue(fieldName:String, fieldValue:String)
		' TODO: FIND OUT THE TYPE VIA THE SCHEMA
		' TODO: Check it has the field to set in the first place
		Self._fieldCount:+ 1
		Self._fieldValues.Insert(fieldName, fieldValue)
	End Method

	' TODO: Is there a need for this?
	Method _setFieldValueObject(fieldName:String, fieldValue:Object)
		Self._fieldCount:+ 1
		Self._fieldValues.Insert(fieldName, fieldValue)
	End Method


	' --------------------------------------------------
	' -- Construction & Initialisation
	' --------------------------------------------------

	''' <summary>Initialises the internals of a ComponentTemplate object.</summary>
	Method New()
		Self._fieldValues = New TMap
	End Method

	''' <summary>Creates and initialises a new ComponentTemplate object and returns it.</summary>
	''' <returns>The newly created ComponentTemplate object.</returns>
	Function Create:ComponentTemplate(schema:ComponentSchema = Null)
		Local this:ComponentTemplate = New ComponentTemplate

		this._schema = schema

		Return this
	End Function

	Function CreateFromSchema:ComponentTemplate(schema:ComponentSchema)
		Local this:ComponentTemplate = New ComponentTemplate

		this._schema = schema
		this.copyFromSchema(schema)

		Return this
	End Function


	' --------------------------------------------------
	' -- Debugging
	' --------------------------------------------------

	Method toString:String()
		Local o:String = "ComponentTemplate[" + Self.getSchemaName() + "] {~n"

		For Local name:String = EachIn Self._fieldValues.Keys()
			o:+ "~t" +  name + " => " + self.GetFieldValue(name) +  "~n"
		Next

		o:+ "}"

		Return o
	End Method

End Type
