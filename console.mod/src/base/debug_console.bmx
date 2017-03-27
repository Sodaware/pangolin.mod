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

	' Appearance
	Field _fontName:String		''' The name of the font this console uses
	Field _speed:Int			''' The speed at which the console moves (During transitions)
	
	' Dimensions & Location
	Field xPos:Int				''' The X position of the console on screen.
	Field yPos:Int				''' The Y position of the console on screen.
	Field m_Width:Int			''' The width of the console image.
	Field m_Height:Int			''' The height of the console image.
	Field m_TextRows:Int		''' The number of rows of text to display.
	
	' Input / Output
	Field m_InputBuffer:String	''' Text contained in the input buffer.
	Field m_OutputBuffer:TList	''' StringList containing output from operations
	Field m_CommandLog:TList	''' StringList of all commands that have been entered.
	Field m_CommandPos:Int		''' Position in the command log
	
	' State
	Field m_State:Int			''' The state the current console is in.
	Field m_Visible:Int			''' Whether or not the console is visible
	Field m_Active:Int			''' Whether or not the console is active.
	
	' Commands / Variables
	Field m_Commands:TMap		''' Map of commands -> function handles
	
	' Internal Resources
	Field gfx_Console:TImage	''' The image displayed by the console
	Field gfx_Background:TImage	''' The default background.
	Field m_Font:TImageFont		''' The font used by the console
	Field snd_Appear:TSound		''' Handle to the source played when the console appears
	Field snd_Disappear:TSound	''' Handle to the source played when the console disappears
	
	

	
	
	' --------------------------------------------------
	' -- Appearance setting functions
	' --------------------------------------------------
	
	''' <summary>Sets the font used by the Console.</summary>
	''' <param name="this">Console to modify.</param>
	''' <param name="p_FontName">The name of the font.</param>
	''' <param name="p_Size">The size of the font.</param>
	''' <param name="p_Bold">If true, the font will be bold.</param>
	''' <param name="p_Italic">Italic or not.</param>
	''' <param name="p_Underline"></param>
	''' <remarks></remarks>
	''' <returns></returns>
	''' <subsystem></subsystem>
	''' <example></example>
	Method setFont(p_FontName:String, p_Size:Int, p_Bold:Int = False, p_Italic:Int = False)
		
		' Cleanup existing font if present
		If (Self.m_font) Then Self.m_Font = Null
		
		Local fntStyle:Int	= 0
		
		If p_Bold Then fntStyle = BOLDFONT
		If p_Italic Then fntStyle = fntStyle & ITALICFONT
		
		' Set font name & load it
		Self._fontName	= p_FontName
		Self.m_Font		= LoadImageFont(p_FontName, p_Size, fntStyle)
		
		' Update internal vars
		If Self.m_Font = Null Then 
			Self.m_TextRows = (Self.m_Height - 10) / 10 - 2
		Else
			'		SetFont(this\m_Font)
			Self.m_TextRows = (Self.m_Height - 10) / Self.m_Font.Height() - 2
		EndIf		
		' Re-render
	'	Self.RenderImage()
		
	End Method
	
	Method setBackground(backgroundImage:TImage)
		
		If backgroundImage <> Null Then
			
			Self.gfx_Background	= backgroundImage
			Self.m_Height		= Self.gfx_Background.height
			Self.m_Width		= Self.gfx_Background.width
			
			' Free old console image
			If Self.gfx_Console Then Self.gfx_Console = Null
			
			' Create new console image & mask
			Self.gfx_Console = CreateImage(Self.m_Width, Self.m_Height, 1, DYNAMICIMAGE )
		'	MaskImage this\gfx_Console, 255, 0 ,255
		
			' Update internal vars
			Self._speed = Self.m_Height / 10
			
			If Self.m_Font Then
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
		
		Local keyHandled:Int 	= False
		
		If KeyHit(KEY_LEFT) Then
			keyHandled = True
			FlushKeys()
		EndIf
		
		If KeyHit(KEY_UP)  Then
			If Self.m_CommandLog.Count() > 0 And Self.m_CommandPos >= 0 Then 
				Self.m_InputBuffer = String(Self.m_CommandLog.ValueAtIndex(Self.m_CommandPos))

				If Self.m_CommandPos > 0 Then
					Self.m_CommandPos:- 1
				EndIf
				
			EndIf
			FlushKeys() 
			Return True			
		EndIf
	
		If KeyHit(KEY_DOWN) Then
			If Self.m_CommandPos < Self.m_CommandLog.Count() - 1 Then 
				Self.m_CommandPos = Self.m_CommandPos + 1
				Self.m_InputBuffer = String(Self.m_CommandLog.ValueAtIndex(Self.m_CommandPos))
			Else
				Self.m_InputBuffer	= ""
			EndIf
			FlushKeys() 
			Return True			
		EndIf	

		' Not a system key - try something else		
		Local currentChar:Int	= GetChar()

		
			
		
		' Backspace
		Select currentChar
			
			Case KEY_BACKSPACE
				Self.m_InputBuffer = Left(Self.m_InputBuffer, Len(Self.m_InputBuffer) - 1) 
				keyHandled = True		
			
			Case KEY_ENTER
				
				' Run the command
				Self.m_CommandLog.AddLast(Self.m_InputBuffer)
				Self.m_CommandPos = Self.m_CommandLog.Count() - 1
			
				Self.m_OutputBuffer.AddLast(Self.m_InputBuffer)
			'		Self.RenderImage()	
				' Console_WriteLine(this, "]" + this\m_InputBuffer)
				' Console_Process(this)
				Self.RunCommand(Self.m_InputBuffer)
			
				Self.m_InputBuffer = ""
				keyHandled = True
					
		End Select
	
	
		If keyHandled = False And currentChar > 0 Then 
			Self.m_InputBuffer = Self.m_InputBuffer + Chr(currentChar)
			keyHandled = True
		EndIf
	
		If keyHandled Then FlushKeys()
		FlushKeys()
		Return keyHandled
		
	End Method
	
	
	' --------------------------------------------------
	' -- Output handling
	' --------------------------------------------------
	
	Method Write(text:String)
		Self.m_OutputBuffer.AddLast(text)
	'	Self.RenderImage()
	End Method
	
	Method WriteLine(line:String)
		Self.m_OutputBuffer.AddLast(line)
	'	Self.RenderImage()
	debuglog line
	End Method
	
		
	' --------------------------------------------------
	' -- Command handling
	' --------------------------------------------------
	
	Function Handle_DlogWrite:Object(id:Int,data:Object,context:Object )
		Local this:DebugConsole = DebugConsole(context)
		If this <> Null Then this.WriteLine("dlog: " + String(data))
	End Function
	
	Method AddCommandHandler:Int(commandName:String, parentObject:Object, handler:Int(parent:Object, console:IConsole, args:TList))
		Self.m_Commands.Insert( ..
			commandName.ToLower(), ..
			ConsoleCommandHandler.Create(parentObject, handler) ..
		)
	End Method
	
	Method AddCommandHandlerObject:Int(handler:Object) 
		' Get a list of functions in the object that match the signature
		' Add them
	End Method
	
	Method runCommand(line:String)
	
		' Store the full input line
		Self._lastInputLine = line
		
		' Extract the command name
		Local commandName:String = Lower(Mid(line, 0, line.Find(" ") + 1))
		If commandName = "" Then commandName = Lower(line)
		
		If Self.HasCommand(commandName)
			Self.ExecuteCommand(commandName, DebugConsole.SplitCommand(line))
			Return
		End If
		
		Local handler:ConsoleCommandHandler = ConsoleCommandHandler(Self.m_Commands.ValueForKey(commandName))
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
	
	Method Update()
	
		Select Self.m_State
			
			Case DebugConsole.STATE_HIDDEN
				If KeyDown( KEY_GRAVE ) Then
					Self.m_Visible = True
					Self.m_State = DebugConsole.STATE_APPEARING
					'Self.RenderImage()
					If Self.snd_Appear <> Null Then PlaySound(Self.snd_Appear)
					FlushKeys()
				EndIf
				
			Case DebugConsole.STATE_APPEARING
				If Self.yPos < 0 Then
					Self.yPos = Self.yPos + Self._speed
				Else
					Self.yPos = 0
					Self.m_State = DebugConsole.STATE_ACTIVE
				EndIf
				
			Case DebugConsole.STATE_DISAPPEARING
				If Self.yPos > 1 - Self.m_Height Then
					Self.yPos = Self.yPos - Self._speed
				Else
					Self.m_State = DebugConsole.STATE_HIDDEN
					Self.m_Visible = False
				EndIf
			
			Case DebugConsole.STATE_ACTIVE
				If KeyDown( KEY_GRAVE ) Then
					Self.m_State = DebugConsole.STATE_DISAPPEARING
					If Self.snd_Disappear <> Null Then PlaySound(Self.snd_Disappear)
				Else
					Self.HandleInput()
				EndIf
			
		End Select

		
	End Method
	
	Method Render()
		
		If Self.m_Visible = False Then Return
		
		DrawImage Self.gfx_Console, Self.xPos, Self.yPos
		DrawImage Self.gfx_Background, Self.xPos, Self.yPos
		Self.RenderText()
		
	End Method
	
	Method RenderImage()
		
		
		If brl.Graphics.GraphicsHeight() = 0 Then Return
			
		local xScale:Float, yScale:Float
		GetVirtualScale(xScale, yScale)
		
		setScale(1 / xScale, 1 / yScale)


		'	If Self.gfx_Background <> Null Then
		DrawImage(Self.gfx_Background, 0, 0)
		Self.RenderText()
				
		
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
	
	Method RenderText:Int()
		
		Local oldFont:TImageFont = GetImageFont()
		SetImageFont(Self.m_Font)
		
		SetColor(255, 255, 255)

		Local listSize%		''' The size of the output buffer
		Local listPos%		''' Position within the output buffer
		Local xPos%			''' X Position To draw current line at
		Local yPos%			''' Y Position To draw current line at
		Local currentLine$	''' Current line To draw.
	
		' TODO: Cache this
		Local fntHeight:Int = TextHeight("`j") / 2
	
	
		' Get list size
		listSize = Self.m_OutputBuffer.Count() - 1
	
		' TODO: Scale should depend on virtual resolution
		SetScale 0.5, 0.5
		
		' Iterate through output	
		For listPos = 0 To Self.m_TextRows
		
			If listSize - listPos > -1 Then
			
				xPos 		= 0 + 9
				yPos 		= Self.yPos + Self.m_Height - 35 - (listPos * fntHeight)
				currentLine = String(Self.m_OutputBuffer.ValueAtIndex(listSize - listPos))
				
				SetColor 0, 0, 0		; DrawText currentLine, xPos + 1, yPos + 1
				SetColor 255, 255, 255	; DrawText currentLine, xPos,  yPos
				
			EndIf
			
			If listPos > 11 Then Exit
		Next
	
		' Draw input buffer
		' TODO: Replace with constants / class dependant calls
		';Font_Draw(this\xPos + 5, this\yPos + this\m_Height - 12, "]" + this\m_InputBuffer + "_")
'		SetColor 0, 0, 0		; DrawText "]" + Self.m_InputBuffer + "_", Self.xPos + 5, Self.yPos + Self.m_Height - 13
'		SetColor 255, 255, 255	; DrawText "]" + Self.m_InputBuffer + "_", Self.xPos + 4, Self.yPos + Self.m_Height - 14
		SetColor 0, 0, 0		; DrawText "]" + Self.m_InputBuffer + "_", 10, Self.m_Height - 18 + Self.yPos
		SetColor 255, 255, 255	; DrawText "]" + Self.m_InputBuffer + "_", 9, Self.m_Height - 19 + Self.yPos
	
		
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
	
	''' <summary>Creates, initialises And returns a New Console Object.</summary>
	''' <param name="p_Background">HANDLE to the image for this console.</param>
	''' <returns>A newly create and initialised Console object.</returns>
	''' <subsystem></subsystem>
	Function Create:DebugConsole(p_Background:TImage, p_FontName:String = "MS Dialog", p_FontSize:Int = 10)
		
		' - Check inputs
		if p_Background = null then return null
		
		Local this:DebugConsole = New DebugConsole
		
		' Initialise resources
		this.SetBackground(p_Background)
		this.SetFont(p_FontName, p_FontSize)
		
		' Set location & speed
		this._speed	= this.m_Height / 10
		this.xPos 	= 0
		this.yPos 	= 0 - this.m_Height
		
		Return this
		
	End Function	
	
	Method New()
		
		' Initialise lists
		Self.m_OutputBuffer	= New TList
		Self.m_CommandLog	= New TList
		Self.m_Commands	 	= New TMap
	
		' Setup state
		Self.m_State		= DebugConsole.STATE_HIDDEN
		Self.m_Active		= False
		
	End Method

End Type
