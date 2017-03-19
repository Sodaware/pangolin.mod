' ------------------------------------------------------------------------------
' -- src/content_db_loader.bmx
' -- 
' -- A helper class for loading the content database. Not all that great, but
' -- works for now.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------

' TODO: Fix this up, it's terrible :D


Type ContentDbLoader
	
	Function LoadTemplateFromFile(db:ContentDb, fileName:String)
		ContentDbLoader._LoadTemplate(db, fileName)
	End Function
	
	Function LoadTemplateFromArchive(db:ContentDb, zipIn:ZipReader, fileName:String)
		ContentDbLoader._LoadTemplate(db, fileName, zipIn)
	End Function

	Function loadComponentSchema:TList(fileName:String)
		
		' TODO: Should we cache these? Takes 3ms, so probably not
		Local id:TTypeId = TTypeId.ForName("ComponentSchemaSerializer")
		For Local loader:TTypeId = EachIn id.DerivedTypes()
			Local serializer:ComponentSchemaSerializer = ComponentSchemaSerializer(loader.NewObject())
			If serializer.canLoad(fileName) Then
				Return serializer.loadComponentSchema(fileName)
			EndIf
		Next
		
		Return Null
		
	End Function
	
	Function loadEntityTemplates:TList(db:ContentDb, fileName:String)
		
		Local id:TTypeId = TTypeId.ForName("ContentDbSerializer")
		For Local loader:TTypeId = EachIn id.DerivedTypes()
			Local serializer:ContentDbSerializer = ContentDbSerializer(loader.NewObject())
			If serializer.canLoad(fileName) Then
				Local entities:TList = serializer.loadEntities(db, fileName)
				db.buildTemplates()
				Return entities
			EndIf
		Next

		Return Null
				
	End Function
		
	' -- Private
	Function _LoadTemplate(db:ContentDb, fileName:String, zipIn:ZipReader = Null)
		
		Local id:TTypeId = TTypeId.ForName("ContentDbSerializer")
		For Local loader:TTypeId = EachIn id.DerivedTypes()
			Local serializer:ContentDbSerializer = ContentDbSerializer(loader.NewObject())
			If serializer.CanLoad(fileName) Then
				If zipIn Then
					serializer.Load(db, zipIn.ExtractFile(fileName))
				Else
					serializer.Load(db, fileName)
				EndIf
			EndIf
		Next
		
	End Function


End Type