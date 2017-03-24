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
	' -- Public API
	' ------------------------------------------------------------
	
	Method setIdentifier(name:String)
		Self._identifier = name
	End Method
	
	Method getIndentifier:String()
		Return Self._identifier
	End Method
	
	Method setVisible(isVisible:Byte = True)
		self._isVisible = isVisible
	End Method
	
	Method hide()
		Self.setVisible(False)
	End Method
	
	Method show()
		Self.setVisible(True)
	End Method

	Method isVisible:Byte()
        Return Self._isVisible
	EndMethod
	
	''' <summary>Get the Z-Index of this renderable object.</summary>
	Method getZIndex:Short()
		Return Self._zIndex
	End Method
	
	''' <summary>
	''' Set the sprite's z-index. Requests with a higher z-index are rendered in
	''' front of requests with lower numbers,
	''' <summary>
	Method setZIndex(zIndex:Short)
		Self._zIndex = zIndex
	End Method
	
	Method isIgnoringCamera:Byte()
		Return Self._ignoreCamera
	End Method
	
	Method ignoreCamera:AbstractRenderRequest(ignore:Byte = True)
		Self._ignoreCamera = ignore
		Return Self
	End Method
	
	Method move(xOff:Float, yOff:Float)
    	' Do nothing (should be overridden)
	End Method
	
	Method getX:Float() Abstract
	Method getY:Float() Abstract
	
			
	' ------------------------------------------------------------
	' -- Abstract Methods
	' ------------------------------------------------------------
	
	Method update(delta:Float) Abstract
	Method render(tweening:Double, camera:AbstractRenderCamera, isFixed:Int = False) Abstract
	
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
		Self._zIndex 	= 1
		Self._isVisible = True
	End Method
	
End Type
