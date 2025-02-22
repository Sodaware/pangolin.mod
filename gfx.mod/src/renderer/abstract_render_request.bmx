' ------------------------------------------------------------------------------
' -- src/renderer/abstract_render_request.bmx
' --
' -- Abstract class that renderable objects should extend. Objects that do not
' -- require any location information (such as fixed backgrounds) can extend
' -- from this. Other items, such as sprites and gui objects should extend
' -- AbstractSpriteRequest instead.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "abstract_render_camera.bmx"

Type AbstractRenderRequest Abstract

	Field _identifier:String	'''< Optional name
	Field _zIndex:Short			'''< Z-Index, used for sorting
	Field _ignoreCamera:Byte	'''< Is this a fixed object or not
	Field _isVisible:Byte		'''< Is object visible?

	' ------------------------------------------------------------
	' -- Required Methods
	' ------------------------------------------------------------

	''' <summary>Get the X position of this render item.</summary>
	Method getX:Float() Abstract

	''' <summary>Get the Y position of this render item.</summary>
	Method getY:Float() Abstract

	''' <summary>Update this render item.</summary>
	Method update(delta:Float) Abstract

	''' <summary>Render the render item.</summary>
	Method render(tweening:Double, camera:AbstractRenderCamera, isFixed:Byte = False) Abstract

	' ------------------------------------------------------------
	' -- Public Identifiers
	' ------------------------------------------------------------

	Method setIdentifier(name:String)
		Self._identifier = name
	End Method

	Method getIndentifier:String()
		Return Self._identifier
	End Method

	' ------------------------------------------------------------
	' -- Visibility
	' ------------------------------------------------------------

	''' <summary>Set the visibility of this request.</summary>
	''' <param name="isVisible">True of make request visible, false to hide it.</param>
	Method setVisible(isVisible:Byte = True)
		self._isVisible = isVisible
	End Method

	''' <summary>Make this request visible.</summary>
	Method show()
		Self.setVisible(True)
	End Method

	''' <summary>Hide this request.</summary>
	Method hide()
		Self.setVisible(False)
	End Method

	''' <summary>Is this object visible?</summary>
	Method isVisible:Byte()
		Return Self._isVisible
	EndMethod

	''' <summary>Is this object hidden?</summary>
	Method isHidden:Byte()
		Return Not Self._isVisible
	End Method

	' ------------------------------------------------------------
	' -- Visibility
	' ------------------------------------------------------------

	''' <summary>
	''' Set the sprite's z-index.
	'''
	''' Requests with a higher z-index are rendered in front of requests with
	''' lower numbers,
	''' </summary>
	Method setZIndex(zIndex:Short)
		Self._zIndex = zIndex
	End Method

	''' <summary>Get the Z-Index of this renderable object.</summary>
	Method getZIndex:Short()
		Return Self._zIndex
	End Method

	' ------------------------------------------------------------
	' -- Camera
	' ------------------------------------------------------------

	''' <summary>
	''' Set if this request should ignore the camera or not.
	'''
	''' Requests that ignore the camera are drawn at their exact coordinates,
	''' and requests that use the camera are offset by the camera's position.
	'''
	''' Most requests will want to use the camera, but things like UI requests
	''' or overlays should ignore it.
	''' </summary>
	''' <param name="ignore">If true will ignore the camera.</param>
	Method ignoreCamera:AbstractRenderRequest(ignore:Byte = True)
		Self._ignoreCamera = ignore

		Return Self
	End Method

	Method isIgnoringCamera:Byte()
		Return Self._ignoreCamera
	End Method

	' ------------------------------------------------------------
	' -- Stubs
	' ------------------------------------------------------------

	Method move(xOff:Float, yOff:Float)
		' Do nothing (should be overridden)
	End Method

	Method setX:AbstractRenderRequest(x:Float)
		Return Self
	End Method

	Method setY:AbstractRenderRequest(y:Float)
		Return Self
	End Method

	Method setBlendMode:AbstractRenderRequest(blendMode:Byte)
		Return Self
	End Method

	Method setAlpha:AbstractRenderRequest(alpha:Float)
		Return Self
	End Method

	Method getAlpha:Float()
		Return 1
	End Method

	Method setScale:AbstractRenderRequest(xScale:Float, yScale:Float)
		Return Self
	End Method

	' ------------------------------------------------------------
	' -- Hooks
	' ------------------------------------------------------------

	Method onRemoved()

	End Method

	' ------------------------------------------------------------
	' -- Sorting Functions
	' ------------------------------------------------------------

	''' <summary>Sorting function. Use this inside a "Sort" method.</summary>
	Function SortByZIndex:Int(o1:Object, o2:Object)
		Return AbstractRenderRequest(o1).getZIndex() - AbstractRenderRequest(o2).getZIndex()
	End Function

	' ------------------------------------------------------------
	' -- Construction / Destruction
	' ------------------------------------------------------------

	Method New()
		Self._zIndex	= 1
		Self._isVisible = True
	End Method

End Type
