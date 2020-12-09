' ------------------------------------------------------------------------------
' -- src/renderer/abstract_sprite_request.bmx
' --
' -- The most basic renderable sprite.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.max2d
Import brl.linkedlist

Import "animation_handler.bmx"
Import "abstract_render_request.bmx"
Import "../util/graphics_util.bmx"
Import "../util/hex_util.bmx"
Import "../util/position.bmx"


Type AbstractSpriteRequest Extends AbstractRenderRequest Abstract

	' Handles sprite animations, such as rotation and scaling etc
	Field _animationHandler:AnimationHandler

	' Position (this frame, last frame and tweened position)
	Field _currentPosition:Position2D
	Field _previousPosition:Position2D
	Field _tweenedPosition:Position2D

	' Appearance modifiers
	Field _xScale:Float                     '''< X Scale
	Field _yScale:Float                     '''< Y Scale
	Field _rotation:Float                   '''< Rotation
	Field _blendMode:Int    = ALPHABLEND    '''< Blend mode.
	Field _color:Int		= 16777215      '''< Colour packed into an int
	Field _alpha:Float		= 1             '''< Transparency, between 0 and 1
	Field _xHandle:Float	= 0             '''< X handle. Defaults to left side of image.
	Field _yHandle:Float	= 0             '''< Y handle. Defaults to top of image.
	Field _xOrigin:Int      = 0             '''< The X origin to render from.
	Field _yOrigin:Int      = 0             '''< The Y origin to render from.


	' ------------------------------------------------------------
	' -- Animation
	' ------------------------------------------------------------

	Method addAnimation(anim:AbstractSpriteAnimation)
		Self._animationHandler.add(anim)
	End Method

	Method play(animationName:String, speed:Float = 1.0)

	End Method

	' ------------------------------------------------------------
	' -- Resetting positions / appearance values
	' ------------------------------------------------------------

	Method resetPosition(xPos:Float, yPos:Float)
		self._currentPosition.setPosition(xPos, yPos)
		self._previousPosition.setPosition(xPos, yPos)
	End Method

	Method resetAppearance()
		self._xScale = 1.0
		self._yScale = 1.0
		self._alpha  = 1.0
		self._rotation = 0
		Self._color = (255 Shl 16) + (255 Shl 8) + (255)
	End Method


	' ------------------------------------------------------------
	' -- Moving
	' ------------------------------------------------------------

	Method move(xOff:Float, yOff:Float)
		self._currentPosition.addValue(xOff, yOff)
	End Method

	Method movePosition(pos:Position2D)
		self._currentPosition.addPosition(pos)
	End Method

	Method setX:AbstractSpriteRequest(xPos:Float)
		Self._currentPosition.setX(xPos)

		Return Self
	End Method

	Method setY:AbstractSpriteRequest(yPos:Float)
		Self._currentPosition.setY(yPos)

		Return Self
	End Method

	Method getX:Float()
		Return Self._currentPosition._xPos
	End Method

	Method getY:Float()
		Return Self._currentPosition._yPos
	End Method


	' ------------------------------------------------------------
	' -- Setting appearance values
	' ------------------------------------------------------------

	Method setBlendMode:AbstractSpriteRequest(blendMode:Byte)
		Assert(blendMode > 0 And blendMode < 6)
		self._blendMode = blendMode
		return self
	End Method

	Method setColorInt:AbstractSpriteRequest(newColor:Int)
		self._color = newColor
		return self
	End Method

	Method setColorRGB:AbstractSpriteRequest(r:Byte, g:Byte, b:Byte)
		Self._color = 0 + (r Shl 16) + (g Shl 8) + (b)
		return self
	End Method

	Method setColorHex:AbstractSpriteRequest(hexColor:String)
		local r:int, g:int, b:int
		HexToRGB(hexColor, r, g, b)
		Self._color = 0 + (r Shl 16) + (g Shl 8) + (b)
		return self
	End Method

	Method SetScale:AbstractSpriteRequest(xScale:Float, yScale:Float)
		self._xScale = xScale
		self._yScale = yScale
		return self
	End Method

	Method setPosition:AbstractSpriteRequest(xPos:Float, yPos:Float)
		Self._currentPosition.setPosition(xPos, yPos)
		Return Self
	End Method

	Method setPositionX:AbstractSpriteRequest(xPos:Float)
		Self._currentPosition.setPositionX(xPos)
		Return Self
	End Method

	Method setPositionY:AbstractSpriteRequest(yPos:Float)
		Self._currentPosition.setPositionY(yPos)
		Return Self
	End Method

	Method SetAlpha:AbstractSpriteRequest(alpha:Float)
		If alpha <> 1 Then Self.setBlendMode(ALPHABLEND)
		Self._alpha	= alpha
		Return Self
	End Method

	Method setRotation(value:Float)
		Self._rotation = value
	End Method

	Method setHandle(x:Float, y:Float)
		Self._xHandle = x
		Self._yHandle = y
	End Method

	Method setOrigin:AbstractSpriteRequest(x:Int, y:Int)
		Self._xOrigin = x
		Self._yOrigin = y

		Return Self
	End Method
	
	' TODO: Move to a private method
	Method setRenderState()
		' Initialise drawing stuff
		SetColorInt(Self._color)
		brl.max2d.SetScale(Self._xScale, Self._yScale)
		brl.max2d.SetRotation(Self._rotation)
		brl.max2d.SetHandle(Self._xHandle, Self._yHandle)
		brl.max2d.SetBlend(Self._blendMode)
		brl.max2d.SetAlpha(Self._alpha)
		brl.max2d.SetOrigin(Self._xOrigin, Self._yOrigin)
	End Method


	' ------------------------------------------------------------
	' -- Getting values
	' ------------------------------------------------------------

	Method getAnimationHandler:AnimationHandler()
		return self._animationHandler
	End Method

	Method getBlendMode:Int()
		return self._blendMode
	End Method

	Method getColor:Int()
		return self._color
	End Method

	Method getAlpha:Float()
		return self._alpha
	End Method

	Method getPosition:Position2D()
		return self._currentPosition
	End Method

	Method getPreviousPosition:Position2D()
		return self._previousPosition
	End Method

	Method getTweenedPosition:Position2D()
		return self._tweenedPosition
	End Method

	Method GetRotation:Float()
		return self._rotation
	End Method

	Method getScale(xScale:Float Var, yScale:Float Var)
		xScale = self._xScale
		yScale = self._yScale
	End Method

	Method gXScale:Float()
		return self._xScale
	End Method

	Method gYScale:Float()
		return self._yScale
	End Method


	' ------------------------------------------------------------
	' -- Rendering and Updating
	' ------------------------------------------------------------

	Method render(delta:Double, camera:AbstractRenderCamera, isFixed:Byte) Abstract

	Method update(delta:Float)
		self._previousPosition.setPositionObject(self._currentPosition)
		If Self._animationHandler Then Self._animationHandler.Update(delta)
	End Method


	' ------------------------------------------------------------
	' -- Internal Helpers
	' ------------------------------------------------------------

	Method _interpolate(tween:Double)
		Self._tweenedPosition.tween(Self._currentPosition, Self._previousPosition, tween)
	End Method

	Method _updatePreviousPosition()
		self._previousPosition.setPositionObject(self._currentPosition)
	End Method


	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------

	Method New()

		' Set up rendering internals.
		Self._blendMode			= GetBlend()
		Self._currentPosition	= New Position2D
		Self._previousPosition	= New Position2D
		Self._tweenedPosition	= New Position2D
		Self._alpha				= 1
		Self._xScale            = 1
		Self._yScale            = 1
		Self.resetAppearance()

		' Set up animation.
		Self._animationHandler	= AnimationHandler.Create(Self)

	End Method

End Type
