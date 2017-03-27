' ------------------------------------------------------------------------------
' -- src/services/debug_console_service.bmx
' -- 
' -- Implementation of a Quake style debug console as a Pangolin service.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

' Blitz imports
Import brl.audio
Import brl.linkedlist
Import brl.map
Import brl.standardio
Import brl.font
Import brl.freetypefont
Import brl.keycodes
Import brl.retro
Import brl.max2d

Import brl.reflection

Import pangolin.core

Import "../base/debug_console.bmx"


Type DebugConsoleService Extends GameService .. 
	{ implements = "update, render" }

	field _console:DebugConsole
	Field _kernelInfo:KernelInformationService	{ injectable }
	
	
	' ------------------------------------------------------------
	' -- Adding commands
	' ------------------------------------------------------------
	
	Method _autoloadConsole:DebugConsoleService()
		
		' TODO: Allow commands to be active / inactive for debug & release mode (use meta?)
	
		Local cmd:TTypeId = TTypeId.ForName("ConsoleCommand")
		For Local subCommand:TTypeId = EachIn cmd.DerivedTypes()
			Self.addCommand(ConsoleCommand(subCommand.NewObject()))
		Next
		Return Self
		
	End Method
	
	Method addCommand:Int(handler:ConsoleCommand)
       
        If Self._kernelInfo = Null Then Throw "Console has not been added to kernel"
	
        ' Update injectable fields
        handler._addInjectableFields()

		' Inject dependencies
		If handler.hasDependencies() Then
	      For Local dependency:TTypeId = EachIn handler.getDependencies()
			    handler.inject(dependency, Self._kernelInfo.getService(dependency))
			Next
		End If
		
		' Add the command
		Return Self._console.addCommand(handler)
		
	End Method
	
	Method start()
		Super.start()
		Self._autoloadConsole()
	End Method
	
	' ------------------------------------------------------------
	' -- Updating & Rendering
	' ------------------------------------------------------------
	
	Method update(delta:Float)
		Self._console.update()
	End Method
	
	Method render(delta:Float)
		self._console.render()
	End Method
	

	' ------------------------------------------------------------
	' -- Object Creation & Destruction
	' ------------------------------------------------------------

	Method New()
		Self._addInjectableFields()
	End Method
	
	Function Create:DebugConsoleService(p_Background:TImage, p_FontName:String = "MS Dialog", p_FontSize:Int = 10)

		Local this:DebugConsoleService = New DebugConsoleService
		this._console = DebugConsole.Create(p_Background, p_FontName, p_FontSize)
		this._priority = 5
		this._renderPriority = 255
		this._updatePriority = 1
		Return this
		
	End Function
	
End Type
