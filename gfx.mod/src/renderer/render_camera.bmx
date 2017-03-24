' ------------------------------------------------------------------------------
' -- src/renderer/render_camera.bmx
' -- 
' -- Standard camera used by the renderer. Renders all objects in a set of 
' -- bounds.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "abstract_render_camera.bmx"
Import "abstract_sprite_request.bmx"

Import "../util/position.bmx"
Import "../util/rectangle.bmx"

Include "camera_behaviour.bmx"

Type RenderCamera Extends AbstractRenderCamera

	Field _screenPosition:Position2D 	= New Position2D
	Field _position:Position2D          = New Position2D
	Field _previousPosition:Position2D  = New Position2D
	
	Field _bounds:Rectangle2D        	= New Rectangle2D
	
	Field _target:AbstractSpriteRequest
	Field _behaviour:CameraBehaviour
	
	Field width:Int
	Field height:Int
	
	Method isInLeftBounds:Byte()
		Return Self._position._xPos > Self._bounds._position._xPos
	End Method
	
	Method isInRightBounds:Byte()
		Return (Self._position._xPos + (Self.width Shr 1)) < (Self._bounds._position._xPos + Self._bounds._width)
	End Method
	
	Method isInTopBounds:Byte()
		Return Self._position._yPos > Self._bounds._position._yPos
	End Method
	
	Method isInBottomBounds:Byte()
		Return (Self._position._yPos + (Self.height Shr 1)) < (Self._bounds._position._yPos + Self._bounds._height)
	End Method
	
	Method getX:Float()
		Return Self._position._xPos
	End Method
	
	Method getY:Float()
		Return Self._position._yPos
	End Method
	
	Method getWidth:Float()
		Return Self.width
	End Method
	
	Method getHeight:Float()
		Return Self.height
	End Method
	
	Method getPosition:Position2D()
		Return Self._position
	End Method
	
	Method getBounds:Rectangle2D()
		Return Self._bounds
	End Method
	
	Method getTarget:AbstractSpriteRequest()
		Return Self._target
	End Method
	
	Method setPosition(xPos:Int, yPos:Int)
		Self._position.setPosition(xPos, yPos)
	End Method
	
	Method setBounds(startX:Float, startY:Float, width:Float, height:Float)
		Self._bounds.setPosition(startX, startY)
		Self._bounds.setSize(width, height)
	End Method
	
	Method setTarget(target:AbstractSpriteRequest, jumpTo:Byte = True)
		
		if target = Null Then return
	
		Self._target = target
		
		If jumpTo Then
			Self.jumpToTarget()
		End If
		
		Self._behaviour.afterTargetSet()
		
	End Method

	Method jumpToTarget()
		
		Self._position.setPositionObject(Self._target._currentPosition)
		Self._position._xPos:- (Self.width / 4)
		Self._position._yPos:- (Self.height / 4)
		
		' Clamp to bounds (if set)
		If Self._bounds Then
					
			If Self._position._xPos < Self._bounds.getX() Then
				Self._position._xPos = Self._bounds.getX()
			ElseIf Self._position._xPos + (Self.getWidth() / 2) > Self._bounds.getX() + Self._bounds.getWidth() Then
				Self._position._xPos = Self._bounds.getX() + Self._bounds.getWidth() - (Self.getWidth() / 2)
			End If
			
			If Self._position._yPos < Self._bounds.getY() Then
				Self._position._yPos = Self._bounds.getY()
			ElseIf Self._position._yPos + (Self.getHeight() / 2) > Self._bounds.gety() + Self._bounds.getHeight() Then
				Self._position._yPos = Self._bounds.getY() + Self._bounds.getHeight() - (Self.getHeight() / 2)
			End If
			
		EndIf
		
	End Method
		
	' TODO: Rename this!
	Method getTargetPosition:position2d()
		If Self._target = Null Then Return Null
		Return Position2D.Create( ..
			Self._target.getPosition()._xPos - Self._position._xPos, ..
			Self._target.getPosition()._yPos - Self._position._yPos ..
		)
	End Method
	
	Method hasTarget:Byte()
		Return Self._target <> Null
	End Method
	
	Method setBehaviour(behaviour:CameraBehaviour)
		Self._behaviour = behaviour
		Self._behaviour.setCamera(Self)
		Self._behaviour.afterCameraSet()
	End Method
	
	Method update(delta:Float)
		Self._behaviour.update(delta)
	End Method
	
	Function Create:RenderCamera(width:Int, height:Int, xPos:Int = 0, yPos:Int = 0)
		Local this:RenderCamera = New RenderCamera
		this.width = width
		this.height = height
		this.setPosition(xPos, yPos)
		this.setBehaviour(New CameraBehaviour)
		Return this
	End Function
	
End Type
