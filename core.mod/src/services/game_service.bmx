' ------------------------------------------------------------------------------
' -- src/services/game_service.bmx
' --
' -- The base type that all services should extend.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.reflection
import brl.hook
Import sodaware.blitzmax_injection


Type GameService Extends IInjectable

	Global g_HookId:Int = AllocHookId()

	Field _id:Int                   '''< Id number of the service.
	Field _canKill:Byte             '''< Can this service be killed?
	Field _priority:Byte            '''< Service priority. Lower values are executed earlier in the loop.
	Field _isRunning:Byte           '''< Is the service running?
	Field _renderPriority:Byte      '''< Render priority. Lower values are executed earlier in the loop.
	Field _updatePriority:Byte      '''< Update priority. Lower values are executed earlier in the loop.


	' ------------------------------------------------------------
	' -- Public interface
	' ------------------------------------------------------------

	''' <summary>Get the unique identifier for this service.</summary>
	Method getId:Int()
		Return Self._id
	End Method

	''' <summary>Get the priority for this service.</summary>
	Method getPriority:Byte()
		return self._priority
	End Method

	''' <summary>Get the RENDER priority for this service.</summary>
	Method getRenderPriority:Byte()
		Return Self._renderPriority
	End Method

	''' <summary>Get the UPDATE priority for this service.</summary>
	Method getUpdatePriority:Byte()
		Return Self._updatePriority
	End Method

	''' <summary>Check if the service is running or not.</summary>
	''' <return>True if service is running, false if not.</return>
	Method isRunning:Byte()
		Return Self._isRunning
	End Method


	' ------------------------------------------------------------
	' -- Priority Setting
	' ------------------------------------------------------------

	''' <summary>
	''' Set the priority for the service.
	'''
	''' Sets the priority for rendering and updating to the `priority` value and
	''' runs the hook assigned to the service.
	''' </summary>
	''' <param name="priority">
	''' Value between 0 and 255. Lower values are executed earlier in the loop.
	''' </param>
	Method setPriority(priority:Byte)

		' Set new priority
		Self._priority			= priority
		Self._updatePriority	= priority
		Self._renderPriority	= priority

		' Alert listeners that priorities have been changed
		RunHooks(GameService.g_HookId, Self)

	End Method

	''' <summary>Set the update priority of the service.</summary>
	''' <param name="priority">Priority value. Lower values execute sooner.</param>
	Method setUpdatePriority(priority:Byte)

		' Set new update priority
		Self._updatePriority	= priority

		' Alert listeners that priorities have been changed
		RunHooks(GameService.g_HookId, Self)

	End Method

	''' <summary>Set the render priority of the service.</summary>
	''' <param name="priority">Priority value. Lower values execute sooner.</param>
	Method setRenderPriority(priority:Byte)

		' Set new render priority
		Self._renderPriority	= priority

		' Alert listeners that priorities have been changed
		RunHooks(GameService.g_HookId, Self)

	End Method


	' ------------------------------------------------------------
	' -- Starting and Stopping
	' ------------------------------------------------------------

	''' <summary>Start the service. Calls "onResume" once service is started.</summary>
	Method start()
		Self._isRunning = True
		Self.onResume()
	End Method

	''' <summary>Stop the service. Calls "onSuspend" once service is stopped.</summary>
	Method stop()
		Self._isRunning = False
		Self.onSuspend()
	End Method


	' ------------------------------------------------------------
	' -- Stub methods
	' ------------------------------------------------------------

	''' <summary>Called when the service is initialized.</summary>
	Method onInit()
	End Method

	''' <summary>Called when the service is stopped/suspended.</summary>
	Method onSuspend()
	End Method

	''' <summary>Called when the service is started/resumed.</summary>
	Method onResume()
	End Method

	''' <summary>Called when the service must free its resources.</summary>
	Method free()
	End Method

	''' <summary>Called during the kernel's update loop.</summary>
	Method update(delta:Float)
	End Method

	''' <summary>Called during the kernel's render loop.</summary>
	Method render(delta:Float)
	End Method


	' ------------------------------------------------------------
	' -- Priority sot support
	' ------------------------------------------------------------

	''' <summary>Compare two services for sorting using the service's priority.</summary>
	Method Compare:Int(withObject:Object)

		Local otherService:GameService = GameService(withObject)

		If Self._priority = otherService._priority Then Return 0

		If Self._priority > otherService._priority Then
			Return 1
		Else
			Return -1
		End If

	End Method


	' ------------------------------------------------------------
	' -- Construction / Destruction
	' ------------------------------------------------------------

	Method New()
		Self.init()
	End Method

	''' <summary>
	''' Initialize the service. Child classes should call Super.init()
	''' before running their own init code.
	''' </summary>
	Method init()

		Self._canKill			= True
		Self._priority			= 127
		Self._renderPriority	= 127
		Self._updatePriority	= 127

		Self._addInjectableFields()

	End Method

End Type
