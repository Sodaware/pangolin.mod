' ------------------------------------------------------------------------------
' -- systems/sweeper_entity_system.bmx
' -- 
' -- System for processing entities that are about to be deleted.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type SweeperEntitySystem Extends EntitySystem Abstract
	
	Method isSweeper:Byte()
		Return True
	End Method

	' This is set to false so it doesn't run during normal execution
	Method checkProcessing:Short() Final
		Return False
	End Method
	
	Method initialize()
		Super.initialize()
	End Method
	
End Type
