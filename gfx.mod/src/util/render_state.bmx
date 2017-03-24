' ------------------------------------------------------------------------------
' -- src/util/scale_image.bmx
' --
' -- A render state captures information about current rendering settings, and
' -- can be used to restore them later.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

import brl.max2d

Type RenderState
    
    ' -- Colours
	Field _clsColorR:Int
	Field _clsColorG:Int
	Field _clsColorB:Int
	
	Field _colorR:Int
	Field _colorG:Int
	Field _colorB:Int
	
	Field _maskColorR:Int
	Field _maskColorG:Int
	Field _maskColorB:Int
	
	' -- Rendering Appearance
	Field _alpha:Float
	Field _blendMode:Int
	Field _rotation:Float
	Field _scaleX:Float
	Field _scaleY:Float

	' Sprite rendering
	Field _handleX:Float
	Field _handleY:Float
	Field _originX:Float
	Field _originY:Float

	' -- Fonts
	Field _font:TImageFont

    ' -- View port	
	Field _viewportX:Int
	Field _viewportY:Int
	Field _viewportWidth:Int
	Field _viewportHeight:Int

	
	' ------------------------------------------------------------
	' -- Capturing / Using states
	' ------------------------------------------------------------
	
	''' <summary>Captures and stores the current render state.</sumnary>
	Method capture()
        
	    self._alpha        = GetAlpha()
		self._font         = GetImageFont()
		self._blendMode    = GetBlend()
		self._rotation     = GetRotation()
		
		GetScale(self._scaleX, self._scaleY)
		
		' Get current colours
		GetColor(self._colorR, self._colorG, self._colorB)
		GetClsColor(self._clsColorR, self._clsColorG, self._clsColorB)		
		GetMaskColor(self._maskColorR, self._maskColorG, self._maskColorB)
		
		GetHandle(self._handleX, self._handleY)
		GetOrigin(self._originX, self._originY)
		
		GetViewport(self._viewportX, self._viewportY, self._viewportWidth, self._viewportHeight)
		
	End Method
	
	''' <summarys>Restores the render state.</summary>
	Method restore()
        
	    SetAlpha(self._alpha)
		SetImageFont(self._font)
		SetBlend(self._blendMode)
		SetRotation(self._rotation)
		
		SetScale(self._scaleX, self._scaleY)
			
		SetColor(self._colorR, self._colorG, self._colorB)
		SetClsColor(self._clsColorR, self._clsColorG, self._clsColorB)
		SetMaskColor(self._maskColorR, self._maskColorG, self._maskColorB)
		
		SetHandle(self._handleX, self._handleY)
		SetOrigin(self._originX, self._originY)
		
		SetViewport(self._viewportX, self._viewportY, self._viewportWidth, self._viewportHeight)
		
	EndMethod
	
	
	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------
	
	Method New()
        self.capture()
	End Method
	
End Type
