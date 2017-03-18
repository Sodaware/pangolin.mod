' ------------------------------------------------------------------------------
' -- src/resource_types/animation_Resource.bmx
' -- 
' -- Resource type to wrap an animation. An animation is made up of a number of
' -- framesets, each of which is made up of the individual frames to show.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.max2d

Import "../base_resource.bmx"

''' <summary>AnimationResource is a set of animation frames to display.</summary>
Type AnimationResource Extends BaseResource ..
	{ resource_type = "animation" }
	
	Field _loopCount:Int = 0
	Field _frameTime:Int = 0
	Field _frameSets:TMap
	Field _animCount:Int = 0			
	
	
	' ------------------------------------------------------------
	' -- Public API
	' ------------------------------------------------------------
	
	''' <summary>Get internal handle.</summary>
	Method _get:Object()
		
	End Method
	
	''' <summary>Load the resource.</summary>
	Method _load()
		
	End Method
	
	''' <summary>Free the resource.</summary>
	Method _free()
		
	End Method
	
	Method countAnimations:Int()
		Return Self._animCount
	End Method
	
	''' <summary>Returns an empty array if nothing found (can't return null)</summary>
	Method getFrameset:Int[](name:String)
		Return Int[](Self._frameSets.ValueForKey(name))
	End Method
			
	
	' ------------------------------------------------------------
	' -- Loading Definitions
	' ------------------------------------------------------------
	
	Method _loadDefinition()
		
		' Get the loop type (forever / none etc)
		Local loopType:String = Self.getDefinition().getField("loop")
		If loopType <> "" Then
			If loopType = "forever" Then
				Self._loopCount = -1
			Else 
				Self._loopCount = Int(loopType)
			End If
		End If
		
		Self._frameTime = Int(Self.getDefinition().getField("frame_time"))
		
		' Load each frame
		Self._frameSets = New TMap
		
		Local frames:TMap = Self.getDefinition().getData("animation_frames")
		For Local animName:String = EachIn frames.Keys()
			
			' Get frames!
			Local rawFrames:String[] =  String(frames.ValueForKey(animName)).Split(",")
			Local frameData:Int[]    = New Int[rawFrames.Length]
			
			For Local i:Int = 0 To frameData.length - 1
				frameData[i] = Int(rawFrames[i].Trim())
			Next
			
			Self._animCount:+ 1
			Self._frameSets.Insert(animName, frameData)
			
		Next
				
	End Method
	
End Type
