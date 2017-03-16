' ------------------------------------------------------------------------------
' -- game_base.bmx
' --
' -- Base types that all Pangolin games should extend. Handles most of the
' -- common parts, such as screen management, events and object management.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.timer

Import pangolin.core
Import pangolin.gfx


''' <summary>
''' Base type for all Pangolin based games to extend. Creates a kernel handles 
''' setting up most of the common parts, such as screen management, events 
''' and the main game loop.
''' </summary>
Type GameBase

	' -- Core event identifiers
	Const EVENT_LOOP_TICK:Int			= -1001
	
	' -- Common parts of all game Pangolin based enginee
	Field _finished:Int 				= False
	Field _frameRate:Int				= 60
	Field _kernel:GameKernel			= New GameKernel
	
	
	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------
	
	''' <summary>Sets the game's framerate.</summary>
	''' <param name="frames">The number of frames per second to display.</param>
	Method setFrameRate(frames:Int)
		' TODO: Throw an exception here if the game is running
		Self._frameRate = frames
	End Method
	

	' ------------------------------------------------------------
	' -- Querying
	' ------------------------------------------------------------
	
	Method getFrameRate:int()
		Return self._frameRate
	End Method

	Method isFinished:Byte()
		return self._finished
	End Method
	
	
	' ------------------------------------------------------------
	' -- Event Handling
	' ------------------------------------------------------------
	
	''' <summary>Handles game events and passes them to the appropriate class.</summary>
	''' <param name="id">The event ID.</param>
	''' <param name="date">A TEvent object.</param>
	''' <param name="context">The GameBase that emitted this event.</param>
	''' <return>Any data generated. Basically nothing.</return>
	Function handleEvents:Object(id:Int, data:Object, context:Object)
		If GameBase(context) <> Null Then GameBase(context).HandleEvent(TEvent(data))		
		Return data
	End Function
	
	
	' ------------------------------------------------------------
	' -- Abstract Methods
	' ------------------------------------------------------------
	
	''' <summary>Delegates an event to any function required.</summary>
	Method handleEvent(event:TEvent)
	End Method
	
	
	' ------------------------------------------------------------
	' -- Main game loop / Rendering / Updating
	' ------------------------------------------------------------	
	
	''' <summary>
	''' Runs the main game loop. Updates all services and calls their render 
	''' function if set. Does NOT clear the screen every frame.
	''' </summary>
	Method runLoop()
		
		Local frameTimer:TTimer = CreateTimer(Self._frameRate)
		
		Local delta:Float		= 1000 / Self._frameRate
		Local lastTime:Int		= MilliSecs()
		
		' Start the kernel and all services
		Self._kernel.start()
		
		Repeat

			' Update kernel and run renderer
			Self._kernel.update(delta)
			Self._kernel.render(delta)
			
			' Wait for next frame and flip
			WaitTimer(frameTimer)
			Flip False
			
			' Calculate delta
			delta		= MilliSecs() - lastTime 
			lastTime 	= MilliSecs()
			
		Until Self.isFinished()

		' Stop the kernel and return
		Self._kernel.stop()
				
	End Method

	Method shutdown()
		EndGraphics()
	End Method
	
	
	' ------------------------------------------------------------
	' -- Kernel Helpers
	' ------------------------------------------------------------

	Method addServiceToKernel(service:GameService, serviceType:TTypeId = Null)
		self._kernel.addService(serviceType, service)
	End Method

	' TODO: Rename this (addServiceToKernel?)
	Method _addKernelService(service:GameService, serviceType:TTypeId = Null)
		DebugLog "Deprecated: Use `addServiceToKernel` instead"
		self.addServiceToKernel(service, serviceType)
	End Method

	Method _getKernelService:GameService(serviceType:TTypeId)
		return self._kernel.getService(serviceType)
	End Method
	
	Method _getKernelServiceByName:GameService(serviceTypeName:String)
		return self._kernel.getService(TTypeId.ForName(serviceTypeName))
	End Method
	
	
	' ------------------------------------------------------------
	' -- Construction / Cleanup
	' ------------------------------------------------------------
	
	Method New()
		
		' Create event hook that is called during "handleEvents"
		AddHook(EmitEventHook, GameBase.HandleEvents, Self, 0)
		
	End Method
	
End Type
