' ------------------------------------------------------------------------------
' -- src/util/rectangle.bmx
' --
' -- Represents a rectangle in 2D space.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "position.bmx"

Type Rectangle2D

	Field _position:Position2D
	Field _width:Float
	Field _height:Float


	' ------------------------------------------------------------
	' -- Getting / Setting Position
	' ------------------------------------------------------------

	Method getX:Float()
		Return Self._position._xPos
	End Method

	Method getY:Float()
		Return Self._position._yPos
	End Method

	Method getWidth:Float()
		Return Self._width
	End Method

	Method getHeight:Float()
		Return Self._height
	End Method

	Method getBottom:Float()
		Return Self._position._yPos + Self._height
	End Method

	Method getRight:Float()
		Return Self._position._xPos + Self._width
	End Method

	Method setPosition(xPos:Float, yPos:Float)
		Self._position.setPosition(xPos, yPos)
	End Method

	Method setPositionX(xPos:Float)
		Self._position.setPositionX(xPos)
	End Method

	Method setPositionY(yPos:Float)
		Self._position.setPositionY(yPos)
	End Method

	Method setSize(width:Float, height:Float)
		Self._width = width
		Self._height = height
	End Method

	Method setWidth(width:Float)
		Self._width = width
	End Method

	Method setHeight(height:Float)
		Self._height = height
	End Method

	Method alterWidth:Rectangle2D(value:Float)
		Self._width :+ value

		Return Self
	End Method

	Method alterHeight:Rectangle2D(value:Float)
		Self._height :+ value

		Return Self
	End Method

	Method tween(currentPos:Position2D, previousPos:Position2D, tween:Double)
'		Self._xPos = (Double(currentPos._xPos) * tween) + (Double(previousPos._xPos) * (1.0:Double - tween))
'		Self._yPos = (Double(currentPos._yPos) * tween) + (Double(previousPos._yPos) * (1.0:Double - tween))

		' TODO: Allow tweening to be disabled rather than commenting it out

		Self._position.tween(currentPos, previousPos, tween)
	End Method

	Method containsX:Byte(objectPos:Position2D)
		Return (objectPos._xPos >= Self._position._xPos) And (objectPos._xPos <= Self._position._xPos + Self._width)
	End Method

	Method containsY:Byte(objectPos:Position2D)
		Return (objectPos._yPos >= Self._position._yPos) And (objectPos._yPos <= Self._position._yPos + Self._height)
	End Method

	Method contains:Byte(objectPos:Position2D)
		Return Self.containsX(objectPos) And Self.containsY(objectPos)
	End Method


	' ------------------------------------------------------------
	' -- Construction / Destruction
	' ------------------------------------------------------------

	Function Create:Rectangle2D(xPos:Float,yPos:Float, width:Float, height:Float)
		Local this:Rectangle2D = New Rectangle2D
		this.setPosition(xPos, yPos)
		this.setSize(width, height)
		Return this
	End Function

	Method New()
		Self._position = New Position2D
	End Method

	Method ToString:String()
		Return "Rectangle2D: [" + Self._position._xPos + ", " + Self._position._yPos + "] to [" + (Self._position._xPos + Self._width) + ", " + (Self._position._yPos + Self._height ) + "]"
	End Method

End Type
