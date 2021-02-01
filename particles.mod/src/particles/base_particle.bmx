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

	Field x_pos:Float
	Field y_pos:Float
	Field width:Int
	Field height:Int

	' TODO: Can these be extracted to a single object?
	Field x_velocity:Float
	Field y_velocity:Float
	Field x_acceleration:Float
	Field y_acceleration:Float
	Field x_max_velocity:Float
	Field y_max_velocity:Float
	Field x_drag:Float
	Field y_drag:Float

	' TODO: Extract this to a color thing?
	Field colorRed:Byte
	Field colorGreen:Byte
	Field colorBlue:Byte
	Field lifespan:Float

	Field _alpha:Float
	Field _alphaDecay:Float

	Field _toDelete:Byte = False

	Method onEmit()

	End Method

	Method setColorHex(color:String)
		Local r:Byte, g:Byte, b:Byte
		HexToRGB(color, r, g, b)
		Self.colorRed   = r
		Self.colorGreen = g
		Self.colorBlue  = b
	End Method

	Method update(delta:Float)
		' All velocities should be in pixels per second (so divide this by 1000 and multiply by delta)
		self.x_velocity :+ (self.x_acceleration / 1000.0) * delta
		self.y_velocity :+ (self.y_acceleration / 1000.0) * delta

		self.x_velocity = Self._clampVelocity(self.x_velocity, self.x_max_velocity)
		self.y_velocity = Self._clampVelocity(self.y_velocity, self.y_max_velocity)

		' Add drag if not accelerating
		If self.x_acceleration = 0 And self.x_drag <> 0 Then
			Local x_drag:Float = (self.x_drag / 1000) * delta
			If self.x_velocity - x_drag > 0  Then
				self.x_velocity :- x_drag
			ElseIf self.x_velocity + x_drag < 0 Then
				self.x_velocity :+ x_drag
			Else
				self.x_velocity = 0
			End If
		End If

		' Apply velocities to co-ordinates.
		Self.x_pos :+ (Self.x_velocity / 1000.0) * delta
		Self.y_pos :+ (Self.y_velocity / 1000.0) * delta

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
		Self._alpha = 1
		Self._alphaDecay = 0

		Self.width  = 1
		Self.height = 1
	End Method

End Type
