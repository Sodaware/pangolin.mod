' ------------------------------------------------------------------------------
' -- Pangolin.Entities -- tag_manager.bmx
' -- 
' -- Manages entity tags. Entities can only have a single tag at a time, so
' -- act like a string identifier.
' -- 
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type TagManager Extends BaseManager
	
	Field _entityByTag:TMap		'< Map of tag -> entity
	Field _tagByEntity:TMap		'< Map of entity -> tag

	
	' ------------------------------------------------------------
	' -- Retrieving Data
	' ------------------------------------------------------------

	''' <summary>Get the tag for an entity.</summary>
	Method getEntityTag:String(e:Entity)
		Return String(Self._tagByEntity.ValueForKey(e))
	End Method
	
	''' <summary>Get the entity for a tag.</summary>
	Method getTagEntity:Entity(tag:String)
		Return Entity(Self._entityByTag.ValueForKey(tag))
	End Method
	
	''' <summary>Check if a tag exists.</summary>
	Method isRegistered:Byte(tag:String)
		Return (Self._entityByTag.ValueForKey(tag) <> Null)
	End Method
	
	''' <deprecated>Use getTagEntity</deprecated>
	Method getEntity:Entity(tag:String)
		Return Entity(Self._entityByTag.ValueForKey(tag))
	End Method
	
	
	' ------------------------------------------------------------
	' -- Setting / Removing Tags
	' ------------------------------------------------------------

	''' <summary>Set the tag for an entity.</summary>
	''' <param name="tag">Tag value to set.</param>
	''' <param name="e">Entity to set the tag for.</param>
	Method register(tag:String, e:Entity)
		Self._entityByTag.Insert(tag, e)
		Self._tagByEntity.Insert(e, tag)
	End Method
	
	''' <summary>
	''' Remove a tag from the database. Clears the tag and its linked entity.
	''' </summary>
	Method unregister(tag:String)
		Self._entityByTag.remove(tag)
		Self._tagByEntity.remove(Self.getEntity(tag))
	End Method
	
	''' <summary>Clear an entity's tag.</summary>
	Method remove(e:Entity)
		Self._entityByTag.remove(e.getTag())
		Self._tagByEntity.remove(e)
	End Method
	
	
	' ------------------------------------------------------------
	' -- Debug Helpers
	' ------------------------------------------------------------
	
	Method dumpTags()
		DebugLog "TagManager.tags {"
		For Local key:String = EachIn Self._entityByTag.Keys()
			DebugLog "  " + key + " => " + Self._entityByTag.ValueForKey(key).ToString()
		Next
		DebugLog "}"
	End Method
	
	
	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------
	
	''' <summary>Create a new tag manager for a world.</summary>
	Function Create:TagManager(w:World)
		Local this:TagManager = New TagManager
		this._world = w
		this._entityByTag = New TMap
		this._tagByEntity = New TMap
		Return this
	End Function
	
End Type
