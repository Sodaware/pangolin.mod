' ------------------------------------------------------------------------------
' -- src/renderer/camera_behaviour.bmx
' -- 
' -- Base camera behaviour. Snaps the camera to the position of the target
' -- object if set.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type CameraBehaviour

	Field _camera:RenderCamera
	
	Method setCamera(camera:RenderCamera)
		Self._camera = camera
	End Method
	
	Method afterTargetSet(jump:Byte)
		
	End Method
	
	Method afterCameraSet()
		
	End Method
	
	Method update(delta:Float)
		
		Self._camera._previousPosition.setPositionObject(Self._camera._position)
		
		If Self._camera.hasTarget() Then
			Self._camera._position.setPositionObject(Self._camera._target._currentPosition)
			Self._camera._position._xPos:- (Self._camera.width / 4)  + Self._camera._xOffset
			Self._camera._position._yPos:- (Self._camera.height / 4) + Self._camera._yOffset
		End If
		
	End Method
	
End Type
