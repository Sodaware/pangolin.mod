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

Import pangolin.core

Import "../base/debug_console.bmx"


Type DebugConsoleService Extends GameService ..
	{ implements = "update, render" }

	Field _console:DebugConsole
	Field _kernelInfo:KernelInformationService	{ injectable }


	' ------------------------------------------------------------
	' -- Adding commands
	' ------------------------------------------------------------

	''' <summary>
	''' Add a command to the console. Commands are wrapped in a ConsoleCommand
	''' object.
	''' </summary>
	''' <seealso cref="ConsoleCommand"></seealso>
	Method addCommand:Byte(handler:ConsoleCommand)

		If Self._kernelInfo = Null Then Throw "Console has not been added to kernel"
		If handler = Null Then Throw "Cannot add null command"

		' Don't add if this handler has already been registered.
		If Self._console.hasCommandHandler(handler) Then Return False

		' Update injectable fields.
		handler._addInjectableFields()

		' Inject dependencies.
		If handler.hasDependencies() Then
		  For Local dependency:TTypeId = EachIn handler.getDependencies()
				handler.inject(dependency, Self._kernelInfo.getService(dependency))
			Next
		End If

		' Add the command.
		Return Self._console.addCommand(handler)

	End Method

	Method _autoloadConsole:DebugConsoleService()
		' TODO: Allow commands to be active / inactive for debug & release mode (use meta?)
		Self._autoloadCommands("ConsoleCommand")

		Return Self
	End Method

	Method _autoloadCommands(baseType:String = "ConsoleCommand")
		Local baseCommand:TTypeId = TTypeId.forName(baseType)
		For Local command:TTypeId = EachIn baseCommand.derivedTypes()
			Self.addCommand(ConsoleCommand(command.NewObject()))

			' Add any derived types.
			Self._autoloadCommands(command.name())
		Next
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

	Function Create:DebugConsoleService(backgroundImage:TImage, consoleFontName:String = "MS Dialog", consoleFontSize:Int = 10)

		Local this:DebugConsoleService = New DebugConsoleService

		this._console        = DebugConsole.Create(backgroundImage, consoleFontName, consoleFontSize)
		this._priority       = 5
		this._renderPriority = 255
		this._updatePriority = 1

		Return this

	End Function

End Type
