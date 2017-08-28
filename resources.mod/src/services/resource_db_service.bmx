' ------------------------------------------------------------------------------
' -- src/services/resource_db_service.bmx
' --
' -- Service that wraps a resource database.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.core

Import "../resource_manager.bmx"

Type ResourceDbService Extends GameService
    
    Field _resources:ResourceManager
    
    
    ' ------------------------------------------------------------
    ' -- Retrieving Resources
    ' ------------------------------------------------------------
    
    Method get:BaseResource(resourceName:String, doNotLoad:Byte = False)
        Return Self._resources.getResource(resourceName, doNotLoad)
    End Method
    
    Method getObject:Object(resourceName:String, doNotLoad:Byte = False)
        Local resource:BaseResource = Self.get(resourceName, doNotLoad)
        if resource Then Return resource.get()
    End Method
    
    
    ' ------------------------------------------------------------
    ' -- Loading resources
    ' ------------------------------------------------------------
    
   ''' <summary>Load all assets in a list.</summary>
    Method loadAssets(assets:TList, isLazy:Byte = True)
        For Local asset:String = EachIn assets
            Self.loadResourceFile(asset, isLazy)
        Next
    End Method
    
    ''' <summary>Load resource definitions from a file.</summary>
    Method loadResourceFile(fileName:String, isLazy:Byte = True)
        Self._resources.loadResources(fileName, isLazy)
    End Method
    
    Method reload()
        Self._resources.reloadAll()
    End Method  
    
    
    ' ------------------------------------------------------------
    ' -- Creation / Setup
    ' ------------------------------------------------------------
    
    Method New()
        Self._resources = New ResourceManager
    End Method
    
End Type
