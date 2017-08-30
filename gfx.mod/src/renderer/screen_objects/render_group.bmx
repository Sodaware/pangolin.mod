' ------------------------------------------------------------------------------
' -- src/renderer/screen_objects/render_group.bmx
' -- 
' -- Holds a collection of renderable items.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.linkedlist
Import brl.reflection
Import brl.map
Import brl.max2d

Import pangolin.profiler

Import "../abstract_render_request.bmx"


Type RenderGroup Extends AbstractRenderRequest

	Field _items:TList = New TList
	Field _itemLookup:TMap = New TMap
		
	Method getX:Float()
		Return 0
	End Method
	
	Method getY:Float()
		Return 0
	End Method		
	
	Method move(xOff:Float, yOff:Float)
    	For Local r:AbstractRenderRequest = EachIn Self._items
			r.move(xOff, yOff)
		Next
	EndMethod

	
	' ------------------------------------------------------------
	' -- Adding / Removing items
	' ------------------------------------------------------------
	
	Method add(item:AbstractRenderRequest, name:String = "")
		
		' Check item is not null
		If item = Null Then
			Throw "Cannot add item ~q" + name + "~q to group - null request"
		EndIf
		
		' Add it to request items
		Self._items.AddLast(item)
		
		' Add a lookup
		If name Then
			item.setIdentifier(name)
			Self._itemLookup.Insert(name, item)
		EndIf
		
	End Method
	
	Method addArray(items:AbstractRenderRequest[])
		For Local item:AbstractRenderRequest = EachIn items
			Self.add(item)
		Next
	End Method
	
	Method get:AbstractRenderRequest(name:String)
		Return AbstractRenderRequest(Self._itemLookup.ValueForKey(name))
	End Method
	
	Method remove(item:AbstractRenderRequest)
		Self._items.remove(item)
		item.onRemoved()
	End Method
	
	Method removeByName(name:String)
		Local item:AbstractRenderRequest = Self.get(name)
		If item Then 
			Self._items.remove(item)
			item.onRemoved()
		EndIf
	End Method

	Method sort(sortOrder:Int = True)
		Self._items.sort(sortOrder, AbstractRenderRequest.SortByZIndex)
	End Method
	
	Method clear()
		For Local r:AbstractRenderRequest = EachIn Self._items
			Self.remove(r)
		Next
	End Method
	
	Method onRemoved()
		Self.clear()
	End Method
	
	
	' ------------------------------------------------------------
	' -- Updating & Rendering
	' ------------------------------------------------------------
	
	Method update(delta:Float)
		For Local item:AbstractRenderRequest = EachIn Self._items
			item.update(delta)
		Next
	End Method

	Method render(tween:Double, camera:AbstractRenderCamera, isFixed:Byte = False)
		If Self._identifier Then PangolinProfiler.startProfile("RenderGroup[" + Self._identifier + "]")
		For Local item:AbstractRenderRequest = EachIn Self._items
			If item._isVisible Then
				item.render(tween, camera, isFixed)
			EndIf
		Next
		If Self._identifier Then PangolinProfiler.stopProfile("RenderGroup[" + Self._identifier + "]")
	End Method
	
	
	' ------------------------------------------------------------
	' -- Debug
	' ------------------------------------------------------------
	
	Method trace:String()
	
		Local output:String = "RenderGroup.trace [" + Self.getIndentifier() + "] {~n"
		
		For Local r:AbstractRenderRequest = EachIn Self._items
			Local t:TTypeId = TTypeId.ForObject(r)
			If t.FindMethod("trace") Then
				output:+ String(t.FindMethod("trace").Invoke(r, Null)) + "~n"
			Else
				output:+ "    " + t.Name() + "~n"
			EndIf
		Next
		
		output:+ "}~n"
		
		Return output
		
	End Method
	
	Method countItems:Int()
		Local count:Int = 0
		For Local r:AbstractRenderRequest = EachIn Self._items
			Local t:TTypeId = TTypeId.ForObject(r)
			If t.FindMethod("countItems") Then
				count :+ Int(t.FindMethod("countItems").Invoke(r, Null).ToString())
			Else
				count :+ 1
			EndIf
		Next
		Return count
	End Method
	
End Type
