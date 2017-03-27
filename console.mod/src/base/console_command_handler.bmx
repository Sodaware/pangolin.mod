' ------------------------------------------------------------------------------
' -- src/base/console_command_handler.bmx
' -- 
' -- Wraps for console command functions in a single object.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "iconsole.bmx"

Type ConsoleCommandHandler
	
	Field _parent:Object
	Field _function:Int(parent:Object, parentConsole:IConsole, args:TList)
	
	Function Create:ConsoleCommandHandler(parent:Object, command:Int(parent:Object, parentConsole:IConsole, args:TList))
		Local this:ConsoleCommandHandler = New ConsolecommandHandler
		this._function = command
		this._parent   = parent
		Return this
	End Function
	
	Method execute:Int(parentConsole:IConsole, args:TList)
		Self._function(Self._parent, parentConsole, args)
	End Method
	
End Type
