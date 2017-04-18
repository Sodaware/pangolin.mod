' ------------------------------------------------------------------------------
' -- src/animated_tile.bmx
' --
' -- Animated tiles cycle through a collection of frames.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import sodaware.ObjectBag

Import "tile.bmx"

''' <summary>
''' Represents an animated tile within a tileset. Animated tiles are
''' made up of frames (tile images) and timers (how long the frame is
''' displayed for).
''' </summary>
Type AnimatedTile Extends Tile
	
	' -- Public data
	Field isLooped:Byte = False
	
	' -- Frames and timers
	Field _frameList:ObjectBag
	Field _numberOfFrames:Int
	
	
	' ------------------------------------------------------------
	' -- Getting Information
	' ------------------------------------------------------------
	
	''' <summary>Get the name of this animation.</summary>
	Method getName:String()
		Return String(self.getMeta("name"))
	End Method
	
	''' <summary>Count the number of frames for this animation.</summary>
	Method countFrames:Short()
		Return Self._numberOfFrames
	End Method

	''' <summary>Count the number of timers for this animation.</summary>
	Method countTimers:Int()
		Return Self._numberOfFrames
	End Method
	
	
	' ------------------------------------------------------------
	' -- Getting frame data
	' ------------------------------------------------------------
	
	''' <summary>
	''' Get the the frame (tile id) at OFFSET. Returns -1 if the 
	''' frame offset is invalid.
	''' </summary>
	Method getFrame:Int(offset:Int)
		If offset < 0 Or offset >= Self._numberOfFrames Then Return -1
		Return Self._frame(offset)._tile
	End Method
	
	''' <summary>
	''' Get the the frame timer at OFFSET. Returns 0 if the timer offset
	''' is invalid.
	''' </summary>
	Method getTimer:Int(offset:Int)
		If offset < 0 Or offset >= Self._numberOfFrames Then Return 0
		Return Self._frame(offset)._timer
	End Method
	
	Method _frame:AnimatedTileFrame(offset:Int)
		Return AnimatedTileFrame(Self._frameList.get(offset))
	End Method
	
	
	' ------------------------------------------------------------
	' -- Adding Frames
	' ------------------------------------------------------------
	
	''' <summary>Add a frame (id and timer) to the animation.</summary>
	''' <param name="frameId">The image frame to display for this frame.</param>
	''' <param name="timer">The number of milliseconds to display the frame for.</param>
	Method addFrame(frameId:Int, timer:Int)
		Self._frameList.add(AnimatedTileFrame.Create(frameId, timer))
		Self._numberOfFrames :+ 1
	End Method
	
	
	' ------------------------------------------------------------
	' -- Construction / Destruction
	' ------------------------------------------------------------

	Method New()
		Self._frameList = ObjectBag.Create()
		Self._numberOfFrames = 0
	End Method
	
End Type

Private 

''' <summary>Internal representation of an animated tile frame.</summary>
Type AnimatedTileFrame
	Field _tile:Int
	Field _timer:Int
	
	Function Create:AnimatedTileFrame(frameId:Int, timer:Int)
		Local this:AnimatedTileFrame = New AnimatedTileFrame
		this._tile = frameId
		this._timer = timer
		Return this
	End Function
End Type
