' ------------------------------------------------------------------------------
' -- src/base/console_command_handler.bmx
' -- 
' -- Wrapper for console commands.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "iconsole.bmx"


Type ConsoleCommandHandler
	
	Field m_Parent:Object
	Field m_Function:Int(parent:Object, parentConsole:IConsole, args:TList)
	
	Function Create:ConsoleCommandHandler(parent:Object, command:Int(parent:Object, parentConsole:IConsole, args:TList))
		Local this:ConsoleCommandHandler = New ConsolecommandHandler
		this.m_Function = command
		this.m_Parent   = parent
		Return this
	End Function
	
	Method Execute:Int(parentConsole:IConsole, args:TList)
		Self.m_Function(Self.m_Parent, parentConsole, args)
	End Method
	
End Type
