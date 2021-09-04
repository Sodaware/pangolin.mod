' ------------------------------------------------------------------------------
' -- src/map_coordinate.bmx
' --
' -- Wrap up x/y coordinates used by the tilemap engine.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

''' <summary>Simple structure for storing map co-ordinates.</summary>
Type MapCoordinate
	Field xPos:Int
	Field yPos:Int


	' ------------------------------------------------------------
	' -- Position helpers
	' ------------------------------------------------------------

	''' <summary>
	''' Check if this coordinate is within a specific area.
	'''
	''' This includes if the position touches the edge of the area.
	''' </summary>
	''' <param name="areaX">The minimum X position of the area.</param>
	''' <param name="areaY">The minimum Y position of the area.</param>
	''' <param name="areaWidth">The width of the area.</param>
	''' <param name="areaHeight">The height of the area.</param>
	''' <return>True if position is in the area, false if not.</return>
	Method inArea:Byte(areaX:Int, areaY:Int, areaWidth:Int, areaHeight:Int)
		Return (Self.xPos >= areaX And Self.yPos >= areaY) And (Self.xPos <= (areaX + areaWidth) And Self.yPos <= (areaY + areaHeight))
	End Method


	' ------------------------------------------------------------
	' -- BlitzMax methods
	' ------------------------------------------------------------

	''' <summary>Convert the map co-ordinates to a formatted string.</summary>
	''' <return>Returns a string formatted as "[x, y]"</return>
	Method toString:String()
		Return "[" + Self.xPos + ", " + Self.yPos + "]"
	End Method

	''' <summary>Create a new object containing the same data.</summary>
	Method clone:MapCoordinate()
		Return MapCoordinate.Create(Self.xPos, Self.yPos)
	End Method


	' ------------------------------------------------------------
	' -- Construction
	' ------------------------------------------------------------

	''' <summary>Create a new map coordinate with x and y values.</summary>
	''' <param name="x">The X position of these co-ordinates.</param>
	''' <param name="y">The Y position of these co-ordinates.</param>
	''' <return>The new MapCoordinate object.</return>
	Function Create:MapCoordinate(x:Int, y:Int)
		Local this:MapCoordinate = New MapCoordinate

		this.xPos = x
		this.yPos = y

		Return this
	End Function
End Type
