' ------------------------------------------------------------------------------
' -- Pangolin.Entities -- system_manager.bmx
' -- 
' -- Used to keep track of systems and retrieve them. Should not be called
' -- directly, but instead called via a World instance.
' -- 
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


''' <summary>
''' Used to keep track of systems and retrieve them. Should not be called
''' directly, but instead called via a World instance.
''' </summary>
Type SystemManager Extends BaseManager
	
	Field _systems:TMap				'< Map of System TType => System instant
	Field _systemList:ObjectBag		'< List of all registered systems
	Field _sweeperList:ObjectBag	'< List of all registered sweeper systems.
	
	
	' ------------------------------------------------------------
	' -- Adding / Retrieving / Removing Systems
	' ------------------------------------------------------------
	
	''' <summary>Get an unordered collection of all systems.</summary>
	Method getSystems:ObjectBag()
		Return Self._systemList
	End Method
	
	''' <summary>Get a system based on its Type</summary>
	Method getSystem:EntitySystem(t:TTypeId)
		If t = Null Then Return Null
		Return EntitySystem(Self._systems.ValueForKey(t))
	End Method
	
	''' <summary>Add a system to the SystemManager.</summary>
	''' <param name="system">The System to add.</param>
	Method addSystem:EntitySystem(system:EntitySystem)
		
		' TODO: Should there be some hooks here?
		
		' Check system is valid
		If system = Null Then Throw "Cannot add a null system"
	
		' Cache the TTypeId for this system
		Local systemType:TTypeId = TTypeId.ForObject(system)
		
		' Register component interests for the system.
		system._autoRegisterComponentTypes()
		
		' Register the system with this world.
		system.setWorld(Self._world)
		
		' Add as a sweeper if needed
		If system.isSweeper() Then Self._addSweeperSystem(system)
		
		' Add all systems to the internal list and lookup
		Self._addSystem(system, systemType)
		
		' Setup bit for fast access
		system.setSystemBit(SystemBitManager.getBitFor(systemType))
		
		' Return the system
		Return system
			
	End Method
	
	''' <deprecated>Use addSystem</deprecated>
	Method setSystem:EntitySystem(system:EntitySystem)
		Return Self.addSystem(system)
	End Method
	
	''' <summary>Clear all systems from the system manager.</summary>
	Method clearSystems()
		
		' Run the cleanup command on all systems
		For Local system:EntitySystem = EachIn Self._systemList
			system.cleanup()
		Next

		' Clear all containers
		Self._sweeperList.clear()
		Self._systemList.clear()
		Self._systems.Clear()
		
	End Method
	
	''' <summary>Remove a system.</summary>
	Method removeSystem(system:EntitySystem)
		system.cleanup()
		Self._systemList.removeObject(system)
		Self._systems.Remove(TTypeId.ForObject(system))
	End Method
	
	''' <summary>Count the number of registered systems.</summary>
	Method countSystems:Int()
		Return Self._systemList.getSize()
	End Method
	
	''' <summary>
	''' Refresh an entity. Notifies all systems that the entity has changed 
	''' so that they can add/remove their interest.
	''' </summary>
	Method refreshEntity(e:Entity)
		For Local system:EntitySystem = EachIn Self._systemList
			system.change(e)
		Next
	End Method
	
	
	' ------------------------------------------------------------
	' -- Initializing / Executing
	' ------------------------------------------------------------
	
	''' <summary>Initialize all registered systems.</summary>
	Method initializeAll()	
		For Local s:EntitySystem = EachIn Self._systemList
			s.initialize()
		Next
	End Method

	''' <summary>Process all systems.</summary>	
	Method processAll()	
		For Local s:EntitySystem = EachIn Self._systemList
			s.process()
		Next
	End Method
	
	''' <summary>Process all enabled sweepers.</summary>
	Method processSweepers()
		For Local s:EntitySystem = EachIn Self._sweeperList
			If s.isEnabled() Then s.process()
		Next
	End Method
	
	
	' ------------------------------------------------------------
	' -- Internal structure access
	' ------------------------------------------------------------
	
	Method _addSystem(system:EntitySystem, systemType:TTypeId)
		Self._systems.Insert(systemType, system)
		If Self._systemList.contains(system) = False Then
			Self._systemList.add(system)
		EndIf
	End Method

	Method _addSweeperSystem(system:EntitySystem)
		If Self._sweeperList.contains(system) = False Then
			Self._sweeperList.add(system)
		EndIf
	End Method
	
	
	' ------------------------------------------------------------
	' -- Construction / Destruction
	' ------------------------------------------------------------
	
	Function Create:SystemManager(w:World)
		
		Local this:SystemManager = New SystemManager
		this._World = w
		Return this
		
	End Function
	
	Method New()
		Self._systems     = New TMap
		Self._systemList  = ObjectBag.Create()
		Self._sweeperList = ObjectBag.Create()
	End Method
	
End Type
