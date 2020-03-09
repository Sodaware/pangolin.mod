' ------------------------------------------------------------------------------
' -- src/renderer/sprite_animation/abstract_sprite_animation.bmx
' --
' -- Base type for sprite animations to extend.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Const CENTER_X:Int      = 1
Const CENTER_Y:Int      = 2
Const CENTER_SCREEN:Int = 4


Type AbstractSpriteAnimation Abstract

	Field _isFinished:Byte	= False

	Method isFinished:Byte()
		Return Self._isFinished
	End Method
	
	Method finished()
		Self._isFinished = True
	End Method
	
	Method setParent(parent:Object) Abstract
	Method update(delta:Float) Abstract	


End Type
