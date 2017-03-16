' ------------------------------------------------------------------------------
' -- src/services/screen_manager_service/game_screen.bmx
' --
' -- A single screen within the game. Can be used as a background for other
' -- screens, or as a self-contained state.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

import brl.linkedlist
import pub.freejoy
import pangolin.gfx

import "screen_manager.bmx"


Type GameScreen extends IGameScreen

	' -- Screen states
	Const STATE_TransitionOn:Int			= 1		'''< Screen is appearing
	Const STATE_Active:Int		 			= 2		'''< Screen is running
	Const STATE_TransitionOff:Int			= 3		'''< Screen is disappearing
	Const STATE_Hidden:Int					= 4		'''< Screen is not visible

	Field State:Int									'''< Current state of this screen
	
	' -- Internal info	
	Field _isPopup:Int						= False
	Field _noFocus:Int						= False
	Field _isCovered:Int					= False
	Field _isExiting:Int					= False
	Field _transitionOffTime:Int
	
	Field _group:RenderGroup
	Field __renderer:SpriteRenderingService = Null	' { injectable } ' <- Remove this now that injector includes parent data
	
	''' <summary>Check if the screen is hidden.</summary>
	Method isHidden:Int()
		return self.State = STATE_Hidden
	End Method

	Method isPopup:Int()
		Return Self._isPopup
	End Method
	
	Method add(obj:AbstractRenderRequest, name:String = "")
		Self._group.add(obj, name)
	End Method
	
	Method remove(obj:AbstractRenderRequest)
		Self._group.remove(obj)
	End Method
	
	Method removeByName(name:String)
		Self._group.removeByName(name)
	End Method
	
	''' <summary>Get the render group associated with this screen.</summary>
	Method getRenderGroup:RenderGroup()
		Return Self._group
	End Method
	
	
	' ------------------------------------------------------------
	' -- Entry & Exiting
	' ------------------------------------------------------------
	
	Method afterAdd()
		
	End Method

	Method exitScreen()
		
		Self._isExiting	= True
		
		If Self._transitionOffTime <= 0 Then
			
			Self.getParent().RemoveScreen(Self)
			
			For Local c:AbstractRenderRequest = EachIn Self._group._items
				Self._group.remove(c)
			Next
			
			Self.__renderer.remove(Self._group)
			
		End If
		
		Self.leave()
		
		'FlushKeys()
		'FlushJoy()
		
	End Method
		
	
	' ------------------------------------------------------------
	' -- Updating & Rendering
	' ------------------------------------------------------------
	
	''' <summary>Update the current screen.</summary>
	''' <param name="delta">Delta time in millisecs</param>
	''' <param name="noFocus">Does this screen have focus?</param>
	''' <param name="covered">Is this screen covered</param>
	Method update(delta:Float = 0, noFocus:Int = False, covered:Int = False)
		Self._noFocus	= noFocus		
	End Method 
	
	''' <summary>Render the current screen</summary>
	''' <param name="delta">Delta time in milliseconds</param>
	Method render(delta:Float = 0)
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------
	
	Method New()
		Self._group	= New RenderGroup
	End Method
	
End Type
