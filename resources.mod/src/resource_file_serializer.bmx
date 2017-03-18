' ------------------------------------------------------------------------------
' -- src/resource_file_serializer.bmx
' -- 
' -- The definition for a single resource. Used as a way to abstract resource
' -- information away from a single file format so resources can be loaded
' -- from anything, such as YAML, JSON or XML.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.linkedlist

Import "resource_definition.bmx"


Type ResourceFileSerializer Abstract
	
	Field _definitions:TList
	Field _fileName:String
	Field _isLoaded:Byte		= False
	
	' ------------------------------------------------------------
	' -- Getting Details
	' ------------------------------------------------------------
	
	Method getFilename:String()
		Return Self._fileName
	End Method
	
		
	' ------------------------------------------------------------
	' -- Getting Definitions
	' ------------------------------------------------------------
	
	Method getResources:TList()
		
		If Self._isLoaded = False Then
			Self.loadResources()
		End If	
			
		Return Self._definitions
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Loading Definitions
	' ------------------------------------------------------------
	
	Method loadResources()
		Self._loadResources()
		Self._isLoaded = True
	End Method
	
	Method _add(def:ResourceDefinition)
		Self._definitions.AddLast(def)
	End Method
	
	Method _loadResources() Abstract
	
	
	' ------------------------------------------------------------
	' -- Construction / Destruction
	' ------------------------------------------------------------
	
	Method init(fileName:String)
		Self._fileName = filename
	End Method
	
	Method New()
		Self._definitions = New TList
	End Method

End Type
