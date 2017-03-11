' ------------------------------------------------------------------------------
' -- src/services/kernel_information_service.bmx
' --
' -- A GameService that acts as a proxy so other services can interact with the
' -- kernel without exposing implementation details.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type KernelInformationService Extends GameService
	
	Field _kernel:GameKernel
	
	Method getKernel:GameKernel()
		Return self._kernel
	End Method
	
	Method getServices:GameServiceCollection()
		Return Self._kernel.getServices()
	End Method
	
	Method getService:GameService(serviceType:TTypeId)
		Return Self._kernel.getService(serviceType)
	End Method
	
	
	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------
	
	Function Create:KernelInformationService(kernel:GameKernel)
		Local this:KernelInformationService = New KernelInformationService
		this._kernel	= kernel
		this._priority	= 0
		Return this
	End Function
	
End Type
