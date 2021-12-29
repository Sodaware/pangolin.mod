' ------------------------------------------------------------------------------
' -- src/particle_emitter.bmx
' --
' -- A render object that can emit particles.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "particles_request.bmx"

Type ParticleEmitter Extends ParticlesRequest

	Field minParticles:Int
	Field maxParticles:Int
	Field minFrame:Int
	Field maxFrame:Int
	Field particleSprite:String
	Field animationName:String
	Field framesetName:String
	Field particleLifespan:Float

	Field width:Float
	Field height:Float

	Field minLifespan:Int
	Field maxLifespan:Int

	Field spawnFrequency:Float = 1

	' Internal state
	Field _particleType:TTypeId
	Field _toGenerate:Int = -1
	Field _generated:Int

	Method setX:ParticleEmitter(xPos:Float)
		Self._xPos = xPos

		Return Self
	End Method

	Method setY:ParticleEmitter(yPos:Float)
		Self._yPos = yPos

		Return Self
	End Method

	Method setParticleType:ParticleEmitter(objectType:TTypeId)
		Self._particleType = objectType

		Return Self
	End Method

	Method update(delta:Float)
		Self.generateParticles(delta)
		Self.updateParticles(delta)
	End Method

	Method generateParticles(delta:Float)

		' If spawn frequency is -1, spawn all in one go
		If Self.spawnFrequency = -1 And self._generated = 0 Then
			Self.emitParticles(Self.maxParticles)
		End If

		If Self.spawnFrequency > 0 Then
			If Rnd() < Self.spawnFrequency Then
				If Self._generated > Self.maxParticles Then Return

				Self.emitParticles(1)
			End If
		End If

	End Method

	Method emitParticles(amount:Int)
		For Local i:Int = 1 To amount
			Local p:BaseParticle = BaseParticle(Self._particleType.NewObject())
			Self._particles.add(p)

			Self._generated :+ 1

			p.xPos = Self._xPos + Rand(0, Int(Self.width))
			p.yPos = Self._yPos + Rand(0, Int(Self.height))

			p.onEmit()
		Next
	End Method

	Method updateParticles(delta:Float)
		For Local p:BaseParticle = EachIn Self._particles
			p.update(delta)
			If p._toDelete Then
				Self._particles.removeObject(p)
				Self._generated :- 1
			End If
		Next
	End Method

End Type
