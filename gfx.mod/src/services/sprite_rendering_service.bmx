' ------------------------------------------------------------------------------
' -- src/services/sprite_rendering_service.bmx
' --
' -- Service that wraps the entire rendering process.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.core

Import "../renderer/render_queue.bmx"
Import "../renderer/screen_objects/render_group.bmx"

''' <summary>
''' Service that wraps a RenderQueue and integrates it with the game kernel.
''' This is the recommended way to use the renderer, rather than manually
''' creating a RenderQueue.
''' </summary>
Type SpriteRenderingService Extends GameService .. 
	{ implements = "render, update" }
	
	Field _renderer:RenderQueue
	
	
	' ------------------------------------------------------------
	' -- Camera management
	' ------------------------------------------------------------
	
	Method setCameraPosition(xPos:Float, yPos:Float)
		Self.getCamera().setPosition(xPos, yPos)
	End Method
	
	Method setCamera(camera:RenderCamera)
		Self._renderer.setCamera(camera)
	End Method
	
	Method getCamera:RenderCamera()
		Return Self._renderer.getCamera()
	End Method
	
	
	' ------------------------------------------------------------
	' -- Managing Renderable Entities
	' ------------------------------------------------------------
	
	Method add(obj:AbstractRenderRequest, name:String = "")
		obj._identifier = name
		Self._renderer.add(obj, name)
	End Method
		
	Method getGroup:RenderGroup(name:String)
		Return RenderGroup(Self._renderer.getRequest(name))
	End Method
	
	Method remove(obj:AbstractRenderRequest, deepRemove:Byte = True)
		If obj = Null Then Return

		Self._renderer.remove(obj, deepRemove)
	End Method
	
	Method removeGroup(name:String)
		Self._renderer.removeGroup(name)
	End Method
	
	Method getRenderQueue:RenderQueue()
		Return Self._renderer
	End Method
	
	
	' ------------------------------------------------------------
	' -- Updating and Rendering
	' ------------------------------------------------------------
	
	Method update(delta:Float)
		Self._renderer.update(delta)
	End Method
	
	Method render(delta:Float)
		Self._renderer.render(delta)
	End Method
	
	
	' ------------------------------------------------------------
	' -- Debugging
	' ------------------------------------------------------------
	
	Method trace:String()
		Return Self._renderer.trace()
	End Method
	
	Method countItems:Int()
		Return Self._renderer.countItems()
	End Method
	
	
	' ------------------------------------------------------------
	' -- Construction
	' ------------------------------------------------------------
	
	Method New()
		Self._renderer = New RenderQueue
	End Method
	
End Type
