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
	Const EVENT_LOOP_TICK:Int   = -1001

	' -- Common parts of all game Pangolin based enginee
	Field _finished:Byte        = False
	Field _frameRate:Int        = 60
	Field _kernel:GameKernel    = New GameKernel


	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------

	''' <summary>Set the game's framerate.</summary>
	''' <param name="frames">The number of frames per second to display.</param>
	Method setFrameRate(frames:Int)
		' TODO: Throw an exception here if the game is running
		' TODO: Or at least update the timer?
		Self._frameRate = frames
	End Method


	' ------------------------------------------------------------
	' -- Querying
	' ------------------------------------------------------------

	''' <summary>Get the game's set framerate. Does not calculate the actual fps.</summary>
	''' <return>The number of frames-per-second this game is set to display.</return>
	Method getFrameRate:Int()
		Return Self._frameRate
	End Method

	''' <summary>Check if the main loop has finished.</summary>
	''' <return>True if finished, false if not.</return>
	Method isFinished:Byte()
		Return Self._finished
	End Method


	' ------------------------------------------------------------
	' -- Event Handling
	' ------------------------------------------------------------

	''' <summary>Handles game events and passes them to the appropriate class.</summary>
	''' <param name="id">The event ID.</param>
	''' <param name="data">A TEvent object.</param>
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
			lastTime	= MilliSecs()

		Until Self._finished

		' Stop the kernel and return
		Self._kernel.stop()

	End Method

	Method shutdown()
		EndGraphics()
	End Method


	' ------------------------------------------------------------
	' -- Kernel Helpers
	' ------------------------------------------------------------

	''' <summary>Get the game's kernel instance.</summary>
	Method getKernel:GameKernel()
		Return Self._kernel
	End Method

	''' <summary>Add a service to the game's kernel.</summary>
	''' <param name="service">The GameService object to add to the kernel.</param>
	''' <param name="serviceType">
	''' Optional TTypeId of the service to add. This can be used to create a base
	''' service type (such as AudioService), and then replace it with specific
	''' versions as needed. Uses the type for the `service` param if not provided.
	''' </param>
	Method addServiceToKernel:GameService(service:GameService, serviceType:TTypeId = Null)
		Assert service, "Cannot add a Null service to the kernel"
		Self._kernel.addService(serviceType, service)

		Return service
	End Method

	''' <deprecated>Use `addServiceToKernel` instead.</deprecated>
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
