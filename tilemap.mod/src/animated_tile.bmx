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
	
	
	Field m_TileList:TList
	Field m_TimerList:TList
	
	Field AnimPosition:Int
	Field AnimTimer:Int	
	
	Field NumberOfFrames:Int
	
	Field CurrentImage:Int
	
	Field isLooped:Byte = False
	
	Method countFrames:Short()
		Return Self.m_TileList.Count()
	End Method
	
	Method getFrame:Int(offset:Int)
		Return Int(Self.m_TileList.ValueAtIndex(offset).ToString())
	End Method
	
	Method getTimer:Int(offset:Int)
		Return Int(Self.m_TimerList.ValueAtIndex(offset).ToString())
	End Method

	Method countTimers:Int()
		Return Self.m_TimerList.Count()
	End Method
	
	Method getName:String()
		Return String(self.getMeta("name"))
	End Method
	
	Method New()
		Self._frameList = New TList
		Self.m_TileList = New TList
		Self.m_TimerList = New TList
	End Method
	
End Type

Private 

Type AnimatedTileFrame
	Field _tile:Int
	Field _timer:Int
End Type
