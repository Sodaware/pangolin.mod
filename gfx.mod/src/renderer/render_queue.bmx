' ------------------------------------------------------------------------------
' -- src/renderer/render_queue.bmx
' -- 
' -- Contains a list of objects that can be rendered to the screen.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.max2d
Import brl.linkedlist
Import brl.map
Import brl.reflection
Import sodaware.ObjectBag

Import "abstract_render_request.bmx"
Import "render_camera.bmx"

Type RenderQueue
	
	Field _renderObjects:ObjectBag		'''< Stores all RenderRequest objects
	Field _renderObjectsLookup:TMap		'''< Named sprite lookup
	Field _camera:RenderCamera			'''< Current camera being used to render with
	
	
	' ------------------------------------------------------------
	' -- Setup
	' ------------------------------------------------------------	
	
	Method setCamera(camera:RenderCamera)
		Self._camera = camera
	End Method
	
	Method getCamera:RenderCamera()
		Return Self._camera
	End Method
	
	
	' ------------------------------------------------------------
	' -- Adding / Removing Render Requests
	' ------------------------------------------------------------
	
	''' <summary>Add a render request to the queue.</summary>
	''' <return>The added request.</return>
	Method add:AbstractRenderRequest(obj:AbstractRenderRequest, name:String = "")
		If obj <> Null Then
			Self._renderObjects.add(obj)
			Self._addLookup(obj, name)
		EndIf
		Return obj
	End Method
	
	Method remove(obj:AbstractRenderRequest, deepRemove:Byte = True)
		Self._renderObjects.removeObject(obj)
		obj.onRemoved()
	End Method
	
	Method removeGroup(name:String)
		Local request:AbstractRenderRequest = AbstractRenderRequest(Self._renderObjectsLookup.ValueForKey(name))
		If request Then
			Self._renderObjectsLookup.remove(name)
			Self._renderObjects.removeObject(request)
		End If
	End Method
	
	Method clear(forceDelete:Byte = False)
		Self._renderObjects.clear()
	End Method
	
	Method sort(sortOrder:Int = ObjectBag.SORT_ASC)
		Self._renderObjects.sort(sortOrder, AbstractRenderRequest.SortByZIndex)
	End Method
	
	Method _addLookup(obj:AbstractRenderRequest, name:String)
		If name = "" Or obj = Null Then Return
		Self._renderObjectsLookup.Insert(name, obj)
	End Method
	
	Method getRequest:AbstractRenderRequest(name:String)
		Return AbstractRenderRequest(Self._renderObjectsLookup.ValueForKey(name))
	End Method
	
	
	' ------------------------------------------------------------
	' -- Updating / Rendering
	' ------------------------------------------------------------
	
	Method update(delta:Float)
		
	' [todo] - why twice for the camera?
	
		' Update the camera
		If Self._camera Then Self._camera.update(delta)
			
		' Update position of every object
		For Local item:AbstractRenderRequest = EachIn Self._renderObjects
			item.update(delta)
		Next
		
		' Update the camera
		If Self._camera Then Self._camera.update(delta)
		
	End Method
	
	Method render(delta:Float, clear:Int = False)
		
		' TODO: Viewport should only get set if current viewport is differemt
		
'		Local viewX:Int
'		Local viewY:Int
'		Local viewWidth:Int
'		Local viewHeight:Int
		
		'GetViewport(viewX, viewY, viewWidth, viewHeight)
	
		' This should go : foreach (camera) -> render
		'SetViewport(Self._camera._screenPosition._xPos, Self._camera._screenPosition._yPos, Self._camera.width, Self._camera.height)
		
		' Render all visible items
		For Local item:AbstractRenderRequest = EachIn Self._renderObjects
			If item._isVisible Then
				item.render(delta, Self._camera)
			Else
				DebugLog item.getIndentifier() + " is invisble"
			EndIf
		Next
		
		'SetViewport(viewX, viewY, viewWidth, viewHeight)
		
		' Clear
		If clear Then Self.clear(0)
		
	End Method

	
	' ------------------------------------------------------------
	' -- Debug Methods
	' ------------------------------------------------------------
	
	Method trace:String()
	
		Local output:String = "RenderQueue.trace {~n"
		
		For Local r:AbstractRenderRequest = EachIn Self._renderObjects
			Local t:TTypeId = TTypeId.ForObject(r)
			If t.FindMethod("trace") Then
				output:+ String(t.FindMethod("trace").Invoke(r, Null)) + "~n"
			Else
				output:+ "    " + t.Name() + "~n" 
			EndIf
		Next
		
		output:+ "}"
		
		Return output
		
	End Method
	
	Method countItems:Int()
		Local count:Int = 0
		For Local r:AbstractRenderRequest = EachIn Self._renderObjects
			Local t:TTypeId = TTypeId.ForObject(r)
			If t.FindMethod("countItems") Then
				count :+ Int(t.FindMethod("countItems").Invoke(r, Null).ToString())
			Else
				count :+ 1
			EndIf
		Next
		Return count
	End Method
	
	
	' ------------------------------------------------------------
	' -- Construction
	' ------------------------------------------------------------
	
	Method New()
		Self._renderObjects	= New ObjectBag
		Self._renderObjectsLookup = New TMap
	End Method
		
End Type
