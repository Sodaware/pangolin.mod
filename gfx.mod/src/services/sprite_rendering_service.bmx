' ------------------------------------------------------------------------------
' -- src/services/sprite_rendering_service.bmx
' --
' -- Service that wraps the entire rendering process.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2020 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.core

Import "../renderer/render_queue.bmx"
Import "../renderer/screen_objects/render_group.bmx"

''' <summary>
''' Service that wraps a RenderQueue and integrates it with the game kernel.
'''
''' This is the recommended way to use the renderer, rather than manually
''' creating a RenderQueue.
''' </summary>
Type SpriteRenderingService Extends GameService ..
	{ implements = "render, update" }

	Field _renderer:RenderQueue
	Field _debug:Byte


	' ------------------------------------------------------------
	' -- Camera management
	' ------------------------------------------------------------

	''' <summary>Set the position of the active camera.</summary>
	''' <param name="xPos">The X position of the camera.</param>
	''' <param name="yPos">The Y position of the camera.</param>
	Method setCameraPosition(xPos:Float, yPos:Float)
		Self.getCamera().setPosition(xPos, yPos)
	End Method

	''' <summary>Set the target of the active camera.</summary>
	''' <param name="target">The request to target.</param>
	Method setCameraTarget(target:AbstractSpriteRequest)
		Self.getCamera().setTarget(target)
	End Method

	''' <summary>Set the active camera instance.</summary>
	Method setCamera(camera:RenderCamera)
		Self._renderer.setCamera(camera)
	End Method

	''' <summary>Get the active camera instance.</summary>
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

		If Self._debug Then
			Self.getCamera().debugRender()
		EndIf
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

	Method toggleDebugging()
		Self._debug = Not Self._debug
	End Method

	Method enableDebugging()
		Self._debug = True
	End Method

	Method disableDebugging()
		Self._debug = False
	End Method


	' ------------------------------------------------------------
	' -- Construction
	' ------------------------------------------------------------

	Method New()
		Self._renderer = New RenderQueue
		Self._debug    = False
	End Method

End Type
