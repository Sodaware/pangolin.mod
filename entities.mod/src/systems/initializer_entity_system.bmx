' ------------------------------------------------------------------------------
' -- systems/initializer_entity_system.bmx
' -- 
' -- Base system for initializing entities.
' -- 
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type InitializerEntitySystem Extends EntitySystem Abstract
	
	Method checkProcessing:Short()
		Return False
	End Method
	
End Type
