' ------------------------------------------------------------------------------
' -- src/particles/base_particle.bmx
' --
' -- Base type that all particles must extend. The most basic particle is a
' -- simple rectangle object that has a colour and size.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.gfx

Type BaseParticle Abstract

	Field xPos:Float
	Field yPos:Float
	Field width:Int
	Field height:Int

	' TODO: Can these be extracted to a single object?
	Field xVelocity:Float
	Field yVelocity:Float
	Field xAcceleration:Float
	Field yAcceleration:Float
	Field xMaxVelocity:Float
	Field yMaxVelocity:Float
	Field xDrag:Float
	Field yDrag:Float

	Field color:ColorRgba
	Field lifespan:Float

	Field _alphaDecay:Float
	Field _toDelete:Byte = False


	' ------------------------------------------------------------
	' -- Standard functions
	' ------------------------------------------------------------
	
	Method onEmit()

	End Method

	Method setupRenderValues()
		brl.max2d.SetColor(Self.color.red, Self.color.green, Self.color.blue)
		brl.max2d.SetAlpha(Self.color.alpha)
	End Method
	
	Method setColorHex(color:String)
		Self.color.loadFromHexString(color)
	End Method


	' ------------------------------------------------------------
	' -- Updating and Rendering
	' ------------------------------------------------------------
	
	Method update(delta:Float)
		' All velocities should be in pixels per second (so divide this by 1000 and multiply by delta)
		self.xVelocity :+ (self.xAcceleration / 1000.0) * delta
		self.yVelocity :+ (self.yAcceleration / 1000.0) * delta

		self.xVelocity = Self._clampVelocity(self.xVelocity, self.xMaxVelocity)
		self.yVelocity = Self._clampVelocity(self.yVelocity, self.yMaxVelocity)

		' Add drag if not accelerating
		If self.xAcceleration = 0 And self.xDrag <> 0 Then
			Local xDrag:Float = (self.xDrag / 1000) * delta
			If self.xVelocity - xDrag > 0  Then
				self.xVelocity :- xDrag
			ElseIf self.xVelocity + xDrag < 0 Then
				self.xVelocity :+ xDrag
			Else
				self.xVelocity = 0
			End If
		End If

		' Apply velocities to co-ordinates.
		Self.xPos :+ (Self.xVelocity / 1000.0) * delta
		Self.yPos :+ (Self.yVelocity / 1000.0) * delta

	End Method

	Method _clampVelocity:Float(currentVelocity:Float, maxVelocity:Float)
		If maxVelocity = 0 Then Return currentVelocity

		If Abs(currentVelocity) > maxVelocity Then
			Local is_minus:Int = 1
			If (currentVelocity < 0) Then is_minus = -1
			currentVelocity = (maxVelocity * is_minus)
		End If

		Return currentVelocity
	End Method

	Method destroy()
		Self._toDelete = True
	End Method

	Method New()
		Self._alphaDecay = 0
		Self.width       = 1
		Self.height      = 1
		Self.color       = New ColorRgba
	End Method

End Type
