' ------------------------------------------------------------------------------
' -- src/resource_types/font_resource.bmx
' -- 
' -- Resource type to wrap Blitz TTF fonts.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------



SuperStrict

Import brl.max2d
Import brl.font
Import brl.freetypefont

Import "../base_resource.bmx"


Type FontResource Extends BaseResource .. 
	{ resource_type = "font" }
	
	Field _font:TImageFont					'''< Font handle for this resource
	
	
	' ------------------------------------------------------------
	' -- Public API
	' ------------------------------------------------------------
	
	''' <summary>Get internal handle.</summary>
	Method _get:TImageFont()
		Return Self._font
	End Method
	
	''' <summary>Load the resource.</summary>
	Method _load()

		Select Self.getDefinition().getType()
			
            Case "font"

				Local flags:Int = 0
				
				If Self.getDefinition().getField("weight") = "bold" Then
					flags = flags + BOLDFONT
				EndIf
				
				If Self.getDefinition().getField("style") = "italic" Then
					flags = flags + ITALICFONT
				EndIf
				
				If Self.getDefinition().getField("smoothing") = "on" Then
					flags = flags + SMOOTHFONT
				EndIf

				Self._font = LoadImageFont(..
                    Self.getDefinition().getFileName(), ..
                    Int(Self.getDefinition().getField("size", 16)), ..
					flags .. 
                )

        End Select
		
	End Method
	
	''' <summary>Free the resource.</summary>
	Method _free()
		Self._font = Null
	End Method
			
	
	' ------------------------------------------------------------
	' -- Loading Definitions
	' ------------------------------------------------------------
	
	Method _loadDefinition()
	End Method
	
End Type
