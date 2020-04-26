' ------------------------------------------------------------------------------
' -- src/base/iconsole.bmx
' --
' -- Base class for Pangolin consoles. This isn't a fully fledged console but
' -- can be extended to create a console. See `debug_console.bmx` for an example
' -- of a console.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.map
Import brl.linkedlist
Import brl.hook
Import brl.retro

Import sodaware.blitzmax_injection


Include "console_command.bmx"

Type IConsole

	Field _lastInputLine:String
	Field _commandHandlers:Tmap = New TMap
	
	
	' ------------------------------------------------------------
	' -- Abstract Methods
	' ------------------------------------------------------------
	
	' -- Standard update / rendering
	Method update() Abstract
	Method render() Abstract
	
	' -- Command handling
	Method addCommandHandler:Int(commandName:String, parentObject:Object, handler:Int(parent:Object, console:IConsole, args:TList)) Abstract
	
	' -- Output Methods
	Method writeLine(line:String) Abstract
	Method write(text:String) Abstract
	
	
	' ------------------------------------------------------------
	' -- Public API
	' ------------------------------------------------------------
	
	''' <summary>Adds a command and handler to this console.</summary>
	''' <param name="handler">The command handler object.</param>
	''' <returns>True if handler added, false if not.</returns>
	Method addCommand:Int(handler:ConsoleCommand)
		
		' Check input
		If handler = Null Or handler.Name = "" Then Return False
		
		' Check if command exists already
		If Self._commandHandlers.ValueForKey(handler.Name.ToLower()) <> Null Then
			Throw "Command ~q" + handler.Name + "~q already has a handler attached."
		End If
				
		Self._commandHandlers.Insert(handler.Name.ToLower(), handler)
		handler._setParent(Self)
		
		Return True
		
	End Method
	
	''' <summary>Checks to see if the console has a handler for a command name.</summary>
	''' <param name="commandName">The name of the command to check for.</param>
	''' <returns>True if handler exists, false if not.</returns>
	Method hasCommand:Int(commandName:String)
		Return (Self._commandHandlers.ValueForKey(commandName.ToLower()) <> Null)
	End Method
	
	''' <summary>Checks to see if a handler has already been registered.</summary>
	''' <param name="handler">The handler object to check for.</param>
	''' <returns>True if handler exists, false if not.</returns>
	Method hasCommandHandler:Byte(handler:ConsoleCommand)
		If handler = Null Then Return False
		Return Self.hasCommand(handler.Name)
	End Method

	''' <summary>Executes a command and sends it a list of arguments.</summary>
	''' <param name="commandName">The name of the command to execute.</param>
	''' <param name="args">A list of arguments to pass to the command.</param>
	Method executeCommand(commandName:String, args:TList)
		Local handler:ConsoleCommand = ConsoleCommand(Self._commandHandlers.ValueForKey(commandName.ToLower()))		
		If handler <> Null Then handler.Execute(args)
	End Method
	
	''' <summary>
	''' Adds a hook listener function. These functions can then be used to write to the
	''' console, or perform some other task. This can be useful for custom debug commands
	''' or other major events you want to capture.
	''' </summary>
	''' <param name="hookID">The ID of the hook to listen to.</param>
	''' <param name="functionHandle">The function to call when this hook is activated.</param>
	Method addHookListener(hookID:Int, functionHandle:Object(id:Int,data:Object,context:Object))
		AddHook(hookID, functionHandle, Self)
	End Method
	
End Type
