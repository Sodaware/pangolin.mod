' ------------------------------------------------------------------------------
' -- src/resource_types/sound_resource.bmx
' -- 
' -- Resource type to wrap Blitz sound.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.audio

Import "../base_resource.bmx"

Type SoundResource Extends BaseResource .. 
	{ resource_type = "sound" }
	
	Field _sound:TSound
	Field _loadFlags:Int
	
	
	' ------------------------------------------------------------
	' -- Public API
	' ------------------------------------------------------------
	
	''' <summary>Get internal handle.</summary>
	Method _get:TSound()
		Return Self._sound
	End Method
	
	''' <summary>Load the resource.</summary>
	Method _load()
		Self._sound = LoadSound(Self.getDefinition().getFileName(), Self._loadflags)
		If Self._sound = Null Then DebugLog "Could not load sound file: " + Self.getDefinition().getFileName()
	End Method
	
	''' <summary>Free the resource.</summary>
	Method _free()
		Self._sound = Null
	End Method
			
	
	' ------------------------------------------------------------
	' -- Loading Definitions
	' ------------------------------------------------------------
	
	Method _loadDefinition()
	
		Local looped:String = Self.getDefinition().getField("looped", "0")
		Local isLooped:Byte = (looped.ToLower() = "true")
		
		If isLooped
			Self._loadFlags = Self._loadFlags | SOUND_LOOP
		End If
	
	End Method
	
End Type
