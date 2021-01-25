' ------------------------------------------------------------------------------
' -- src/soda_component_schema_serializer.bmx
' --
' -- Load a component schema that is in SODA format.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.contentdb
Import pangolin.resources

Import sodaware.blitzmax_array
Import sodaware.file_soda

''' <summary>Component schema serializer for Soda file format.</summary>
Type SodaComponentSchemaSerializer Extends ComponentSchemaSerializer

	Method canLoad:Byte(fileName:String)
		Return (ExtractExt(fileName) = "soda")
	End Method

	Method loadComponentSchema:TList(fileName:String)

		' -- Check file exists
		If FileType(fileName) <> FILETYPE_FILE And fileName.Contains("::") = False Then Return Null

		' Load into memory
		PangolinProfiler.startProfile("SodaFile.Load(fileName)")
		Local fileIn:SodaFile = SodaFile.Load(fileName)
		PangolinProfiler.stopProfile("SodaFile.Load(fileName)")

		' Initialise list of schemas in this file
		Local schemaList:TList	= New TList

		' Read all component schemas
		Local schemas:TList		= fileIn.GetNodes("[t:component]")
		For Local grp:SodaGroup = EachIn schemas

			PangolinProfiler.startProfile("SodaFile.getNodes")

			' Create schema
			Local this:ComponentSchema = ComponentSchema.Create(grp.GetIdentifier(), String(grp.GetField("doc")))

			' -- Add requirements
			If grp.GetField("requires") <> Null Then
				If grp.FieldIsArray("requires") Then
					For Local val:String = EachIn TList(grp.GetField("requires"))
						this._addRequirement(val)
					Next
				End If
			End If

			' -- Add internals
			If grp.GetField("internal") <> Null Then
				If grp.FieldIsArray("internal") Then
					For Local val:String = EachIn TList(grp.GetField("internal"))
						this._addInternal(val)
					Next
				End If
			End If

			' -- Add fields
			Local fields:TList = grp.GetChildren()
			For Local fld:SodaGroup = EachIn fields

				Local fieldObject:ComponentField = New ComponentField

				' -- Set details
				fieldObject.setName(fld.GetIdentifier())
				fieldObject.setDataType(String(fld.getField("type")))
				fieldObject.setDefaultValue(String(fld.GetField("default")))
				fieldObject.setDescription(String(fld.GetField("doc")))

				this.addField(fieldObject)

			Next

			PangolinProfiler.stopProfile("SodaFile.getNodes")

			If this <> Null Then schemaList.AddLast(this)

		Next

		Return schemaList

	End Method

End Type
