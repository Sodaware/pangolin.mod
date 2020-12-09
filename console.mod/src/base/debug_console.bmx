' ------------------------------------------------------------------------------
' -- src/base/debug_console.bmx
' -- 
' -- The actual console implementation
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

import pangolin.gfx

Import "iconsole.bmx"
Import "console_command_handler.bmx"


Type DebugConsole Extends IConsole

?win32
	Const KEY_GRAVE:Int 			= 223	
?not win32
	Const KEY_GRAVE:Int 			= 192
?

	' --------------------------------------------------
	' -- Current appearance state constants
	' --------------------------------------------------

	Const STATE_HIDDEN:Int			= 1
	Const STATE_ACTIVE:Int			= 2
	Const STATE_APPEARING:Int		= 3
	Const STATE_DISAPPEARING:Int	= 4

	' -- Appearance
	Field _fontName:String      '''< The name of the font this console uses
	Field _speed:Int            '''< The speed at which the console moves (During transitions)
	
	' -- Dimensions & Location
	Field xPos:Int              '''< The X position of the console on screen.
	Field yPos:Int              '''< The Y position of the console on screen.
	Field _width:Int            '''< The width of the console image.
	Field _height:Int           '''< The height of the console image.
	Field _textRows:Int         '''< The number of rows of text to display.
	
	' Input / Output
	Field _inputBuffer:String   '''< Text contained in the input buffer.
	Field _outputBuffer:TList   '''< StringList containing output from operations
	Field _commandLog:TList     '''< StringList of all commands that have been entered.
	Field _commandPos:Int       '''< Position in the command log
	
	' State
	Field _state:Int            '''< The state the current console is in.
	Field _visible:Int          '''< Whether or not the console is visible
	Field _active:Int           '''< Whether or not the console is active.
	
	' Commands / Variables
	Field _commands:TMap        '''< Map of commands -> function handles
	
	' Internal Resources
	Field gfx_Console:TImage	'''< The image displayed by the console
	Field gfx_Background:TImage	'''< The default background.
	Field _font:TImageFont      '''< The font used by the console
	Field snd_Appear:TSound		'''< Handle to the source played when the console appears
	Field snd_Disappear:TSound	'''< Handle to the source played when the console disappears
	
	
	' --------------------------------------------------
	' -- Appearance setting functions
	' --------------------------------------------------
	
	''' <summary>Sets the font used by the Console.</summary>
	Method setFont(name:String, size:Int, isBold:Byte = False, isItalic:Byte = False)
		
		' Cleanup existing font if present
		If Self._font Then 
			Self._Font = Null
		EndIf
		
		Local fntStyle:Int	= 0
		
		If isBold Then fntStyle = BOLDFONT
		If isItalic Then fntStyle = fntStyle & ITALICFONT
		
		' Set font name & load it
		Self._fontName	= name
		Self._font		= LoadImageFont(name, size, fntStyle)
		
		' Update internal vars
		If Self._font = Null Then 
			Self._textRows = (Self._height - 10) / 10 - 2
		Else
			Self._textRows = (Self._height - 10) / Self._font.Height() - 2
		EndIf
		
	End Method
	
	Method setBackground(backgroundImage:TImage)
		
		If backgroundImage <> Null Then
			
			Self.gfx_Background	= backgroundImage
			Self._height		= Self.gfx_Background.height
			Self._width			= Self.gfx_Background.width
			
			' Free old console image
			If Self.gfx_Console Then Self.gfx_Console = Null
			
			' Create new console image & mask
			Self.gfx_Console = CreateImage(Self._width, Self._height, 1, DYNAMICIMAGE )
		'	MaskImage this\gfx_Console, 255, 0 ,255
		
			' Update internal vars
			Self._speed = Self._height / 10
			
			If Self._font Then
			'	SetFont(this\m_Font)
			'	this\m_TextRows = (this\m_Height - 10) / FontHeight() - 2
			EndIf
			
			' Re-render
		'	Self.RenderImage()
		
		EndIf
		
	End Method
	
	
	' --------------------------------------------------
	' -- Input handling
	' --------------------------------------------------

	Method handleInput:Int(currentKey:Int = 0)
		
		Local keyHandled:Byte = False
		
		If KeyHit(KEY_LEFT) Then
			keyHandled = True
			FlushKeys()
		EndIf
		
		If KeyHit(KEY_UP)  Then
			If Self._commandLog.Count() > 0 And Self._commandPos >= 0 Then 
				Self._inputBuffer = String(Self._commandLog.ValueAtIndex(Self._commandPos))

				If Self._commandPos > 0 Then
					Self._commandPos:- 1
				EndIf
				
			EndIf
			FlushKeys() 
			Return True			
		EndIf
	
		If KeyHit(KEY_DOWN) Then
			If Self._commandPos < Self._commandLog.Count() - 1 Then 
				Self._commandPos = Self._commandPos + 1
				Self._inputBuffer = String(Self._commandLog.ValueAtIndex(Self._commandPos))
			Else
				Self._inputBuffer	= ""
			EndIf
			FlushKeys() 
			Return True			
		EndIf	

		' Not a system key - try something else		
		Local currentChar:Int = GetChar()
		
		' Backspace
		Select currentChar
			
			Case KEY_BACKSPACE
				Self._inputBuffer = Left(Self._inputBuffer, Len(Self._inputBuffer) - 1)
				keyHandled = True
			
			Case KEY_ENTER
				
				' Run the command
				Self._commandLog.AddLast(Self._inputBuffer)
				Self._commandPos = Self._commandLog.Count() - 1
			
				Self._outputBuffer.AddLast(Self._inputBuffer)
				Self.runCommand(Self._inputBuffer)
				
				Self._inputBuffer = ""
				keyHandled = True
					
		End Select
		
		If keyHandled = False And currentChar > 0 Then 
			Self._inputBuffer = Self._inputBuffer + Chr(currentChar)
			keyHandled = True
		EndIf
		
		If keyHandled Then FlushKeys()
		FlushKeys()
		Return keyHandled
		
	End Method
	
	
	' --------------------------------------------------
	' -- Output handling
	' --------------------------------------------------
	
	Method write(text:String)
		Self._outputBuffer.AddLast(text)
	'	Self.RenderImage()
	End Method
	
	Method writeLine(line:String)
		Self._outputBuffer.AddLast(line)
	'	Self.RenderImage()
		DebugLog line
	End Method
	
		
	' --------------------------------------------------
	' -- Command handling
	' --------------------------------------------------
	
	Function Handle_DlogWrite:Object(id:Int, data:Object, context:Object)
		Local this:DebugConsole = DebugConsole(context)
		If this <> Null Then this.WriteLine("dlog: " + String(data))
	End Function
	
	Method addCommandHandler:Int(commandName:String, parentObject:Object, handler:Int(parent:Object, console:IConsole, args:TList))
		Self._commands.Insert( ..
			commandName.ToLower(), ..
			ConsoleCommandHandler.Create(parentObject, handler) ..
		)
	End Method
	
	' TODO: Remove this?
	Method addCommandHandlerObject:Int(handler:Object) 
		' Get a list of functions in the object that match the signature
		' Add them
	End Method
	
	Method runCommand(line:String)
	
		' Store the full input line
		Self._lastInputLine = line
		
		' Extract the command name
		Local commandName:String = Lower(Mid(line, 0, line.Find(" ") + 1))
		If commandName = "" Then commandName = Lower(line)
		
		If Self.hasCommand(commandName)
			Self.executeCommand(commandName, DebugConsole.SplitCommand(line))
			Return
		End If
		
		Local handler:ConsoleCommandHandler = ConsoleCommandHandler(Self._commands.ValueForKey(commandName))
		If handler <> Null Then 
			' Split args in a friendly way (ie obeying strings etc)
			Local args:TList = DebugConsole.SplitCommand(line)
			handler.execute(Self, args)
			args = Null
			GCCollect()
		Else
			DebugLog "DebugConsole: No handler for: " + commandName
		End If
		
	End Method
	
	
	' --------------------------------------------------
	' -- Updating & Rendering
	' --------------------------------------------------
	
	Method update()
	
		Select Self._state
			
			Case DebugConsole.STATE_HIDDEN
				If KeyDown( KEY_GRAVE ) Then
					Self._visible = True
					Self._state = DebugConsole.STATE_APPEARING
					'Self.RenderImage()
					If Self.snd_Appear <> Null Then PlaySound(Self.snd_Appear)
					FlushKeys()
				EndIf
				
			Case DebugConsole.STATE_APPEARING
				If Self.yPos < 0 Then
					Self.yPos = Self.yPos + Self._speed
				Else
					Self.yPos = 0
					Self._state = DebugConsole.STATE_ACTIVE
				EndIf
				
			Case DebugConsole.STATE_DISAPPEARING
				If Self.yPos > 1 - Self._height Then
					Self.yPos = Self.yPos - Self._speed
				Else
					Self._state = DebugConsole.STATE_HIDDEN
					Self._visible = False
				EndIf
			
			Case DebugConsole.STATE_ACTIVE
				If KeyDown( KEY_GRAVE ) Then
					Self._state = DebugConsole.STATE_DISAPPEARING
					If Self.snd_Disappear <> Null Then PlaySound(Self.snd_Disappear)
				Else
					Self.handleInput()
				EndIf
			
		End Select

		
	End Method
	
	Method render()
		
		If Self._visible = False Then Return
		
		DrawImage Self.gfx_Console, Self.xPos, Self.yPos
		DrawImage Self.gfx_Background, Self.xPos, Self.yPos
		Self.renderText()
		
	End Method
	
	Method renderImage()
		
		
		If brl.Graphics.GraphicsHeight() = 0 Then Return
			
		local xScale:Float, yScale:Float
		PangolinGfx.getVirtualScale(xScale, yScale)
		
		setScale(1 / xScale, 1 / yScale)


		'	If Self.gfx_Background <> Null Then
		DrawImage(Self.gfx_Background, 0, 0)
		Self.renderText()
				
		
		GrabImage(Self.gfx_Console, 0, 0)
		GCCollect()
		'	EndIf
		
		
		
		setScale(xScale, yScale)
		
		' Create a pixmap
'		Local g:TGraphics	= p
'		SetGraphics
'		Local scratch:TPixmap	= LoadPixmap(Self.gfx_Console)
'		DrawImage
		
		
		'Local currentBuffer = graphicsbuffer()
	
		' Render to stored image
		' SetBuffer(ImageBuffer(this\gfx_Console))
	
		' Draw background
		' DrawBlock this\gfx_Background, 0, 0
	
		' Render text
		' Console_RenderText(this)
	
		' Reset buffer
		' If currentBuffer Then SetBuffer(currentBuffer)
	End Method
	
	Method renderText:Int()
	
		' TODO: Add some padding rather than hard-coding everything
		
		Local oldFont:TImageFont = GetImageFont()
		SetImageFont(Self._font)
		
		SetColor(255, 255, 255)

		Local listSize:Int			' The size of the output buffer
		Local listPos:Int			' Position within the output buffer
		Local xPos:Int				' X Position To draw current line at
		Local yPos:Int				' Y Position To draw current line at
		Local currentLine:String	' Current line To draw.
	
		' TODO: Cache this
		Local fntHeight:Int = TextHeight("`j") / 2
	
	
		' Get list size
		listSize = Self._outputBuffer.Count() - 1
	
		' TODO: Scale should depend on virtual resolution
		SetScale 0.5, 0.5
		
		' Iterate through output	
		For listPos = 0 To Self._textRows / 0.5
		
			If listSize - listPos > -1 Then
			
				xPos 		= 0 + 9
				yPos 		= Self.yPos + Self._height - 35 - (listPos * fntHeight)
				currentLine = String(Self._outputBuffer.ValueAtIndex(listSize - listPos))
				
				' TODO: Replace this with a method to draw text with a shadow
				SetColor 0, 0, 0
				DrawText currentLine, xPos + 1, yPos + 1
				SetColor 255, 255, 255
				DrawText currentLine, xPos,  yPos
				
			EndIf
			
			If listPos > 11 Then Exit
		Next
	
		' Draw input buffer
		' TODO: Replace with constants / class dependant calls
		';Font_Draw(this\xPos + 5, this\yPos + this\m_Height - 12, "]" + this\m_InputBuffer + "_")
'		SetColor 0, 0, 0		; DrawText "]" + Self.m_InputBuffer + "_", Self.xPos + 5, Self.yPos + Self.m_Height - 13
'		SetColor 255, 255, 255	; DrawText "]" + Self.m_InputBuffer + "_", Self.xPos + 4, Self.yPos + Self.m_Height - 14
		
		

		' Draw shadow
		SetColor 0, 0, 0
		DrawText "]" + Self._inputBuffer + "_", 10, Self._height - 10 + Self.yPos
		
		' Draw text
		SetColor 255, 255, 255
		DrawText "]" + Self._inputBuffer + "_", 9, Self._height - 9 + Self.yPos
		
		SetScale 1.0, 1.0
		SetImageFont oldfont
		
	End Method

	Function SplitCommand:TList(line:String)
		
		Local args:TList		= New TList
		If line = "" Then Return args
		
		Local currentArg:String = ""
		Local char:String		= ""
		Local inString:Int 		= False
		
		For Local pos:Int = 0 To line.Length - 1
			char = Chr(line[pos])
			
			If char = "~q" Then
				inString = Not(inString)
			ElseIf char = " " And inString = False Then
				args.AddLast(currentArg)
				currentArg = ""
			Else
				currentArg:+ char
			End If
			
		Next
		
		' Strip command?
		args.AddLast(currentArg)
		args.RemoveFirst()
		args.AddFirst(line)
		
		Return args
	
	End Function


	' ------------------------------------------------------------
	' -- Object Creation & Destruction
	' ------------------------------------------------------------
	
	''' <summary>Creates, initialises And returns a new DebugConsole object.</summary>
	''' <param name="backgroundImage">Image for this console.</param>
	''' <returns>A newly create and initialised DebugConsole object.</returns>
	Function Create:DebugConsole(backgroundImage:TImage, consoleFontName:String = "MS Dialog", consoleFontSize:Int = 10)
		
		' - Check inputs
		If backgroundImage = Null Then Return Null
		
		Local this:DebugConsole = New DebugConsole
		
		' Initialise resources
		this.setBackground(backgroundImage)
		this.setFont(consoleFontName, consoleFontSize)
		
		' Set location & speed
		this._speed	= this._height / 10
		this.xPos 	= 0
		this.yPos 	= 0 - this._height
		
		Return this
		
	End Function	
	
	Method New()
		
		' Initialise lists
		Self._outputBuffer	= New TList
		Self._commandLog	= New TList
		Self._commands	 	= New TMap
	
		' Setup state
		Self._state			= DebugConsole.STATE_HIDDEN
		Self._active		= False
		
	End Method

End Type
