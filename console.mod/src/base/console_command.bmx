' ------------------------------------------------------------------------------
' -- src/base/console_command.bmx
' -- 
' -- Base class for an executable console command. All console commands have
' -- access to the kernel and can write output to the console.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type ConsoleCommand Extends IInjectable
	
	' Public
	Field Name:String
	Field Description:String
	Field HelpText:String
		
	' Private
	Field _parentConsole:IConsole
	
	Method getParentConsole:IConsole()
		Return Self._parentConsole
	End Method
	
	' Write some help text to the console
	Method writeHelpText()
		
	End Method
	
	Method write(text:String = "")
		Self._parentConsole.Write(text)
	End Method
	
	Method writeLine(line:String = "")
		Self._parentConsole.WriteLine(line)
	End Method
	
	' Private
	Method _setParent(parent:IConsole)
		Self._parentConsole = parent
	End Method

	Method execute:Int(args:TList) Abstract
   	
End Type
