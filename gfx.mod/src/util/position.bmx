' ------------------------------------------------------------------------------
' -- src/util/position.bmx
' --
' -- Represents a position in 2D space.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Import brl.math

Type Position2D

	Field _xPos:Float
	Field _yPos:Float
	
	
	' ------------------------------------------------------------
	' -- Getting / Setting Position
	' ------------------------------------------------------------
	
	Method setPosition(xPos:float, yPos:int)
		self._xPos = xPos
		self._yPos = yPos
	End Method
	
	Method setPositionX(xPos:Float)
		Self._xPos = xPos
	End Method

	Method setPositionY(yPos:Float)
		Self._yPos = yPos
	End Method

	Method setPositionObject(pos:Position2D)
		Self.setPosition(pos._xPos, pos._yPos)
	End Method
	
	Method clone:Position2D()
		Return Position2D.Create(self._xPos, self._yPos)
	End Method
	
	Method addValue(xOff:FLoat, yOff:FLoat)
		self._xPos :+ xOff
		self._yPos :+ yOff
	End Method

	Method subtractValue(xOff:FLoat, yOff:FLoat)
		self._xPos :- xOff
		self._yPos :- yOff
	End Method

	Method addPosition(p:Position2D)
		self._xPos :+ p._xPos
		self._yPos :+ p._yPos
	End Method

	Method subtractPosition(p:Position2D)
		self._xPos :- p._xPos
		self._yPos :- p._yPos
	End Method
	
	Method multiply(v:Float)
		self._xPos :* v
		self._yPos :* v
	End Method

	Method divide(v:Float)
		Assert(v <> 0.0)
		
		self._xPos :/ v
		self._yPos :/ v
	End Method

	Method normalize()
		self.divide(self.getMagnitude())
	End Method

	Method getMagnitude:Float()
		Return Sqr(..
			(self._xPos * self._xPos) + (self._yPos * self._yPos)..
		)
	End Method

	Method getSquaredMagnitude:Float()
		Return (self._xPos * self._xPos) + (self._yPos * self._yPos)
	End Method

	Method getDot:Float(pos:Position2D)
		return (self._xPos * pos._xPos) + (self._yPos * pos._yPos)
	End Method

	Method getDistance:Float(pos:Position2D)
		
		local xDistance:Float = (self._xPos - pos._xPos)
		local yDistance:Float = (self._yPos - pos._yPos)
		
		Return Sqr(..
			(xDistance * xDistance) + (yDistance * yDistance) ..
		)
		
	End Method

	Method getRotation()
		return ATan2(self._yPos, self._xPos)
	End Method
	
	Method equals:Byte(xPos:Float, yPos:Float)
		Return (Self._xPos = xPos and Self._yPos = yPos)
	End Method
	
	Method inRectangle:Byte(xPos:Float, yPos:Float, width:Float, height:Float)
		Return (Self._xPos >= xPos And Self._yPos >= yPos) And (Self._xPos <= (xPos + width) And Self._yPos <= (yPos + height))
	End Method

	
	Method tween(currentPos:Position2D, previousPos:Position2D, tween:Double)
'		Self._xPos = (Double(currentPos._xPos) * tween) + (Double(previousPos._xPos) * (1.0:Double - tween))
'		Self._yPos = (Double(currentPos._yPos) * tween) + (Double(previousPos._yPos) * (1.0:Double - tween))
		
		' TODO: Allow tweening to be disabled rather than commenting it out

		Self._xPos = currentPos._xPos
		Self._yPos = currentPos._yPos		
	End Method
	
	Method ToString:String()
		Return "POSITION2D[" + Self._xPos + ", " + Self._yPos + "]"
	End Method
	
	
	' ------------------------------------------------------------
	' -- Construction / Destruction
	' ------------------------------------------------------------
	
	Function Create:Position2D(xPos:Float,yPos:Float)
		Local this:Position2D = New Position2D
		this._xPos = xPos
		this._yPos = yPos
		return this
	End Function
	
End Type
