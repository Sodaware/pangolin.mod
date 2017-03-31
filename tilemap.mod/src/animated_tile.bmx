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

Import brl.linkedlist

Import "tile.bmx"

Type AnimatedTile Extends Tile
	Field _frameList:TList
	
	
	Field _tileList:TList
	Field _timerList:TList
	
	Field AnimPosition:Int
	Field AnimTimer:Int	
	
	Field NumberOfFrames:Int
	
	Field CurrentImage:Int
	
	Field isLooped:Byte = False
	
	Method getName:String()
		Return String(self.getMeta("name"))
	End Method
	
	Method countFrames:Short()
		Return Self._tileList.Count()
	End Method

	Method countTimers:Int()
		Return Self._timerList.Count()
	End Method
	
	Method getFrame:Int(offset:Int)
		Return Int(Self._tileList.ValueAtIndex(offset).ToString())
	End Method
	
	Method getTimer:Int(offset:Int)
		Return Int(Self._timerList.ValueAtIndex(offset).ToString())
	End Method
	
	Method addFrame(frameId:Int, timer:Int)
		Self._tileList.AddLast(String(frameId))
		Self._timerList.AddLast(String(timer))
	End Method

	Method New()
		Self._frameList = New TList
		Self._tileList  = New TList
		Self._timerList = New TList
	End Method
	
End Type

Private 

Type AnimatedTileFrame
	Field _tile:Int
	Field _timer:Int
End Type
