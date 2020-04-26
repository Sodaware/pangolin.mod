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


''' <summary>
''' Base class for an executable console command.
'''
''' Console commands MUST set the `Name`, `Description`, and `HelpText`  fields
''' in their constructor. More detailed instructions can be displayed by
''' overriding the `writeUsageText` method.
'''
''' All console commands have access to the kernel and can write output to the
''' console.
''' </summary>
Type ConsoleCommand Extends IInjectable

	' Public information.
	Field Name:String
	Field Description:String
	Field HelpText:String

	' Private
	Field _parentConsole:IConsole

	' ------------------------------------------------------------
	' -- Abstract Methods
	' ------------------------------------------------------------

	''' <summary>
	''' Execute the console command.
	'''
	''' All commands must implement this method and return either True or False
	''' upon completion.
	''' </summary>
	''' <param name="args">
	''' A list of arguments passed to the command. The first argument
	''' will always be the command name.
	''' </param>
	''' <returns>True if the command executed correctly, False if not.</returns>
	Method execute:Int(args:TList) Abstract


	' ------------------------------------------------------------
	' -- Output Functions
	' ------------------------------------------------------------

	''' <summary>Write text to the console without a newline after.</summary>
	Method write(text:String = "")
		Self._parentConsole.Write(text)
	End Method

	''' <summary>Write text to the console and add a newline.</summary>
	Method writeLine(line:String = "")
		Self._parentConsole.WriteLine(line)
	End Method

	''' <summary>
	''' Write a list item to the console.
	'''
	''' List items are usually used in `writeUsageText` to describe sub-commands
	''' of a command. Names in list items are padded with whitespace so that
	''' their descriptions align.
	'''
	''' An example looks like:
	''' " - my item     - A description"
	''' </summary>
	''' <param name="name">The list item.</param>
	''' <param name="description">Optional description of the list item.</param>
	''' <param name="width">Optional whitespace padding width of the name.</param>
	''' <param name="bullet">Optional bullet point override. Should include whitespace.</param>
	''' <param name="sep">Optional name/description separator override. Should include whitespace.</param>
	Method writeListItem(name:String, description:String = "", width:Byte = 14, bullet:String = " -", sep:String = " - ")
		Local listItem:String = bullet + " " + LSet(name, width)

		If description <> "" Then listItem :+ sep + description

		Self.writeLine(listItem)
	End Method


	' ------------------------------------------------------------
	' -- Command Information
	' ------------------------------------------------------------

	''' <summary>
	''' Write the command description and usage text to the console.
	''' </summary>
	Method writeHelpText:Byte()
		Self.writeLine(Self.Description)
		Self.writeUsageText()

		Return True
	End Method

	''' <summary>
	''' Write the command description and usage text to the console.
	'''
	''' Displays the `HelpText` string unless overridden.
	''' </summary>
	Method writeUsageText()
		Self.writeLine(Self.HelpText)
	End Method


	' ------------------------------------------------------------
	' -- Arg Helpers
	' ------------------------------------------------------------

	''' <summary>
	''' Removes the first arg from the list and returns the arg list.
	''' </summary>
	Method cleanArgs:TList(args:TList)
		args.removeFirst()

		Return args
	End Method

	''' <summary>
	''' Check if the args list contains values.
	'''
	''' This should be called after running `cleanArgs`, otherwise it will always
	''' return `True` as the command name is in the list.
	''' </summary>
	''' <return>True if there are values in the list, False if not.</return>
	Method hasArgs:Byte(args:TList)
		Return (args <> Null And args.count() <> 0)
	End Method

	''' <summary>Check if the args list is empty.</summary>
	''' <return>False if there are values in the list, True if not.</return>
	Method areArgsEmpty:Byte(args:TList)
		Return False = Self.hasArgs(args)
	End Method

	''' <summary>Get an arg value at a specific index.</summary>
	Method getArg:String(args:TList, index:Int)
		Return args.ValueAtIndex(index).ToString()
	End Method

	''' <summary>
	''' Get a cleaned arg value at a specific index.
	'''
	''' Converts the arg to lower case and trims and whitespace.
	''' </summary>
	''' <return>The cleaned arg value.</return>
	Method getCleanedArgAt:String(args:TList, index:Int)
		Return Self.getArg(args, index).ToLower().Trim()
	End Method

	''' <summary>Get the last input line entered in the console.</summary>
	Method getLastInputLine:String()
		Return Self._parentConsole._lastInputLine
	End Method


	' ------------------------------------------------------------
	' -- Parent Console
	' ------------------------------------------------------------

	Method _getParent:IConsole()
		Return Self._parentConsole
	End Method

	' Private
	Method _setParent(parent:IConsole)
		Self._parentConsole = parent
	End Method

End Type
