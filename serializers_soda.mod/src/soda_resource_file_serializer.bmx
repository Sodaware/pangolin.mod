' ------------------------------------------------------------------------------
' -- src/soda_resource_file_serializer.bmx
' --
' -- Adds support for loading resource definitions using the SODA file format.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.resources

Import sodaware.blitzmax_array
Import sodaware.file_soda

''' <summary>Resource file serializer using the Soda format.</summary>
Type SodaResourceFileSerializer Extends ResourceFileSerializer ..
	{ extensions = "soda" }


	' ------------------------------------------------------------
	' -- Overrides
	' ------------------------------------------------------------

	''' <summary>Load all resource definitions.</summary>
	Method _loadResources()
		Self._loadFromFile(Self.getFilename())
	End Method


	' ------------------------------------------------------------
	' -- Internal Helpers
	' ------------------------------------------------------------

	''' <summary>
	''' Load resource definitions from a single file. This is done in its own
	''' method (rather than _loadResources) so that include files can be
	''' loaded recursively.
	''' </summary>
	''' <param name="fileName">The file to load from.</param>
	Method _loadFromFile(fileName:String)

		' Load the SODA definition file.
		Local fileIn:SodaFile = SodaFile.Load(fileName)

		' Load the resource node.
		Local resources:SodaGroup = fileIn.GetGroup("resources")

		' Get defaults.
		Local basePath:String    = ExtractDir(Self.getFilename()) + "/"
		Local defaultType:String = String(resources.GetField("default_type"))
		Local namespace:String   = String(resources.Query("namespace"))
		Local skipAutoload:Byte  = ("true" = Lower(resources.queryString("skip_autoload")))

		' Load includes (deprecated).
		Self._loadIncludes(resources.GetField("include"), basePath)

		' Load all resources.
		For Local resource:SodaGroup = EachIn resources.GetChildren()

			' Skip none-resource nodes.
			If resource.GetMeta("t") = "" Then Continue

			' Create definition and load details.
			Local def:ResourceDefinition = New ResourceDefinition

			def._name         = resource.GetIdentifier()
			def._namespace    = namespace
			def._fileName     = fileName
			def._skipAutoload = skipAutoload

			' Override autoload
			If String(resource.getField("skip_autoload")) <> "" Then
				def._skipAutoload = ("true" = String(resource.getField("skip_autoload")))
			EndIf

			If String(resource.GetField("file")) <> "" Then def._fileName = basePath + String(resource.GetField("file"))
			def._resourceType = String(resource.getField("type", -1, defaultType))

			' TODO: Remove the access to internal fields here!!
			Local ignore:String[] = ["type", "name", "file", "skip_autoload"]
			For Local fieldName:String = EachIn resource._fields.Keys()
				If array_contains(ignore, fieldName) = False Then
					def.addField(fieldName, String(resource.GetField(fieldName)))
				EndIf
			Next

			' Load extra data.
			For Local child:SodaGroup = EachIn resource.GetChildren()

				Local extraData:TMap = New TMap

				For Local childField:String = EachIn child._fields.Keys()
					extraData.Insert(childField, String(child.getField(childField)))
				Next

				def._data.Insert(child.Identifier, extraData)

			Next

			' Add to list of resources.
			Self._add(def)

		Next

		fileIn = Null

	End Method

	''' <summary>
	''' Load all include files.
	''' </summary>
	''' <param name="includes">Result of query.</param>
	Method _loadIncludes(includes:Object, basePath:String)

		If includes = Null Then Return

		Select TTypeId.ForObject(includes)

			Case TTypeId.ForName("String")
				Self._loadFromFile(basePath + String(includes))

			Case TTypeId.ForName("TList")
				For Local includeName:String = EachIn TList(includes)
					Self._loadFromFile(basePath + includeName)
				Next

		End Select

	End Method

End Type
