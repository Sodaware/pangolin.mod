' ------------------------------------------------------------------------------
' -- src/drived/graphics_manager.bmx
' --
' -- Wraps BlitzMax graphics in a simple interface. Supports standard and
' -- virtual screen resolutions.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.max2d
Import brl.glmax2d

?Win32
Import brl.d3d7max2d
Import brl.d3d9max2d
?

Import "virtual_screen_resolution.bmx"

''' <summary>
''' Wraps BlitzMax graphics in a simple interface. Supports standard and virtual
''' screen resolutions.
'''
''' Prefer using functions in PangolinGfx the type as they wrap a lot of the
''' internals.
''' </summary>
Type GraphicsManager
	Const DRIVER_TYPE_DX7:Byte      = 1
	Const DRIVER_TYPE_DX9:Byte      = 2
	Const DRIVER_TYPE_OPENGL:Byte   = 3

	Global _instance:GraphicsManager

	Field _driver:TGraphics
	Field _resolution:VirtualScreenResolution
	Field _depth:Int
	Field _width:Int
	Field _height:Int
	Field _refreshRate:Int
	Field _flags:Int                = GRAPHICS_BACKBUFFER | GRAPHICS_ALPHABUFFER
	Field _waitVBlank:Byte
	Field _isWindowed:Byte
	Field _driverType:Int


	' --------------------------------------------------
	' -- Getting Information
	' --------------------------------------------------

	''' <summary>
	''' Get the current GraphicsManager instance. Don't normally need to call
	''' this unless doing something odd.
	''' </summary>
	Function getInstance:GraphicsManager()
		If GraphicsManager._instance = Null Then
			GraphicsManager._instance = New GraphicsManager
		EndIf

		Return GraphicsManager._instance
	End Function

	''' <summary>Get the graphics width in pixels.</summary>
	''' <note>This is the absolute width, not the virtual width.</note>
	''' <return>The graphics width in pixels.</return>
	Method getWidth:Int()
		Return Self._width
	End Method

	''' <summary>Get the graphics height in pixels.</summary>
	''' <note>This is the absolute height, not the virtual height.</note>
	''' <return>The graphics height in pixels.</return>
	Method getHeight:Int()
		Return Self._height
	End Method


	' --------------------------------------------------
	' -- Configuring
	' --------------------------------------------------

	Method setWidth:GraphicsManager(width:Int)
		Self._width = width

		Return Self
	End Method

	Method setHeight:GraphicsManager(height:Int)
		Self._height = height

		Return Self
	End Method

	Method setDepth:GraphicsManager(depth:Int)
		Self._depth = depth

		Return Self
	End Method

	Method setRefreshRate:GraphicsManager(rate:Int)
		Self._refreshRate = rate

		Return Self
	End Method

	Method setIsWindowed:GraphicsManager(isWindowed:Byte)
		Self._isWindowed = isWindowed

		Return Self
	End Method

	Method setWaitVBlank:GraphicsManager(wait:Byte)
		Self._waitVBlank = wait

		Return Self
	End Method

	Method setDriverType:GraphicsManager(driverType:Byte)
		Self._driverType = driverType

		Return Self
	End Method


	' --------------------------------------------------
	' -- Starting and Stopping.
	' --------------------------------------------------

	Method startGraphics()

		' Stop any existing drivers.
		Self.endGraphics()

		' Create new driver
		Select Self._driverType

			Case DRIVER_TYPE_DX7
				?win32
				SetGraphicsDriver(D3D7Max2DDriver())
				?not win32
				throw "You cannot use the D3D7Max2DDriver on this operating system"
				?

			Case DRIVER_TYPE_DX9
				?win32
				SetGraphicsDriver(D3D9Max2DDriver())
				?not win32
				throw "You cannot use the D3D7Max2DDriver on this operating system"
				?

			Case DRIVER_TYPE_OPENGL
				GLShareContexts()
				SetGraphicsDriver(GLMax2DDriver())

		End Select

		' Create graphics mode.
		Self._driver = CreateGraphics(Self._width, Self._height, (Not(Self._isWindowed) * Self._depth), Self._refreshRate, Self._flags)
		If Self._driver = Null Then Throw "Could not make the graphics"

		SetGraphics(Self._driver)

		' Enable virtual resolution.
		If Self._resolution._isEnabled Then Self._resolution.start()

		' Enable input.
		EnablePolledInput()

	End Method

	Method endGraphics()
		If Self._driver = Null Then Return

		CloseGraphics(Self._driver)
		Self._driver = Null
	End Method


	' --------------------------------------------------
	' -- Construction / Destruction
	' --------------------------------------------------

	Method New()

		If GraphicsManager._instance <> Null Then
			Throw "Cannot create more than one instance of GraphicsManager"
		End	If

		Self._resolution = VirtualScreenResolution.getInstance()

	End Method

End Type
