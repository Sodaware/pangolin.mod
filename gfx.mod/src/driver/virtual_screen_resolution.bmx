' ------------------------------------------------------------------------------
' -- src/driver/virtual_screen_resolution.bmx
' --
' -- Add support for virtual screen resolutions. Used for stretching pixels
' -- automatically without having to calculate anything 
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.max2d
Import "../util/graphics_util.bmx"

Type VirtualScreenResolution

	Global _instance:VirtualScreenResolution
	
	Field _width:Float			= 320
	Field _height:Float 		= 240
	Field _stretchDisplay:Byte	= False
	Field _isEnabled:Byte		= True
	
	Function getInstance:VirtualScreenResolution()
		If VirtualScreenResolution._instance = Null Then
			VirtualScreenResolution._instance = New VirtualScreenResolution
		EndIf
		Return VirtualScreenResolution._instance
	End Function
	
	Method getWidth:Float()
		Return Self._width
	End Method
	
	Method getHeight:Float()
		Return Self._height
	End Method
	
	Method getMouseX:Float()
		If Self._isEnabled Then
			Return VirtualMouseX()
		Else
			Return MouseX()
		EndIf
	End Method

	Method getMouseY:Float()
		If Self._isEnabled Then
			Return VirtualMouseY()
		Else
			Return MouseY()
		EndIf
	End Method

	Method start()
		
		' If scaling, recalculate the width
		If Self._stretchDisplay
			Self._width = Self._height * GetAspectRatio()
		End If
		
		' Set the virtual resolution + refresh
		SetVirtualResolution(Self._width, Self._height)
		If Self._isEnabled Then
			SetViewport(0, 0, Self._width, Self._height)
		Else
			SetViewport(0, 0, GraphicsWidth(), GraphicsHeight())
		EndIf
		
	End Method

End Type
