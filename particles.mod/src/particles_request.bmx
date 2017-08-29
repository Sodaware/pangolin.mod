' ------------------------------------------------------------------------------
' -- src/particles_request.bmx
' --
' -- Handles rendering of a collection of particles. This is quicker than
' -- adding each particle as a RenderRequest object.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.gfx
Import "particle_bag.bmx"

Type ParticlesRequest Extends AbstractRenderRequest

	Field _xPos:Float
	Field _yPos:Float
	Field _particles:ParticleBag
	
	Method getX:Float()
		Return Self._xPos
	End Method
	
	Method getY:Float()
		Return Self._yPos
	End Method
	
	Method render(tweening:Double, camera:AbstractRenderCamera, isFixed:Int = False)
		For Local p:BaseParticle = EachIn Self._particles
			SetColor p.colorRed, p.colorGreen, p.colorBlue
			brl.max2d.SetAlpha(p._alpha)
			DrawRect p.x_pos, p.y_pos, p.width, p.height
		Next
		brl.max2d.SetAlpha(1)
	End Method
	
	Method update(delta:Float)
		
	End Method
	
	Method New()
		Self._particles = ParticleBag.Create()
	End Method

End Type
