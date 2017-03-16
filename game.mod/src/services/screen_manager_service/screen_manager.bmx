' ------------------------------------------------------------------------------
' -- src/services/screen_manager_service/screen_manager.bmx
' --
' -- Handles the updating and rendering of IGameScreens and
' -- their transitions.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.linkedlist
Import brl.reflection

Include "igame_screen.bmx"


Type ScreenManager
	
'	Field parentGame:GameBase

	' TODO: Change to "IGameScreenCollection"?
	' TODO: Rename these to be in-line with coding standards
	Field m_Screens:TList			= New TList
	Field screensToUpdate:TList		= New TList

	Field traceEnabled:Int			= False
	
	
	' ------------------------------------------------------------
	' -- Adding / Removing screens
	' ------------------------------------------------------------
		
	''' <summary>Replace the current screen with the new one.</summary>
	Method switchScreen(screen:IGameScreen)
		Self.popScreen()
		Self.addScreen(screen)
	End Method

		
	''' <summary>Add a screen to the manager and enter it.</summary>
	''' <param name="screen">The screen to add.</param>
	Method addScreen(screen:IGameScreen)

		' TODO: Check inputs
		
		' 
		screen.setIsExiting(False)
		screen.setParentManager(self)
		screen.loadresources()
		Self.m_Screens.AddLast(screen)
		screen.Enter()
	End Method
	
	Method popScreen:IGameScreen()
		IGameScreen(Self.m_Screens.Last()).exitScreen()
	End Method
	
	''' <summary>
	''' Removes a screen from the screen manager. You should normally
	''' use IGameScreen.ExitScreen instead of calling this directly, so
	''' the screen can gradually transition off rather than just being
	''' instantly removed.
	''' </summary>
	Method removeScreen:IGameScreen(screen:IGameScreen)
		
		' Free resources for the screen
		screen.FreeResources()
		
		' Remove from lists
		Self.m_Screens.Remove(screen)
		Self.screensToUpdate.Remove(screen)
		
		Return screen
		
	End Method
	
	''' <summary>
	''' Clears all screens from the current list of screens.
	''' </summary>
	Method clearScreens()
		
		For Local screen:IGameScreen	= EachIn Self.m_Screens
			screen.FreeResources()
			Self.m_Screens.Remove(screen)
			Self.screensToUpdate.Remove(screen)
		Next
	
		Self.m_Screens.Clear()
		
	End Method

	''' <summary>
	''' Expose an array holding all the screens. We return a copy rather
	''' than the real master list, because screens should only ever be added
	''' or removed using the AddScreen and RemoveScreen methods.
	''' </summary>
	Method getScreens:IGameScreen[]()
		Return IGameScreen[](Self.m_Screens.ToArray())
	End Method
	
	
	' ------------------------------------------------------------
	' -- Debug Helpers
	' ------------------------------------------------------------
	
	Method traceScreens()
		
		DebugLog "ScreenManager.TraceScreens {"
		For Local screen:IGameScreen = EachIn Self.m_Screens
			Local t:TTypeId = TTypeId.ForObject(screen)
			DebugLog "    " + t.Name() 
		Next
		DebugLog "}"
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Content Loading / Unloading
	' ------------------------------------------------------------
	
	Method loadContent()
		Throw "ScreenManager.loadContent -- Method is deprecated"		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Updating / Rendering
	' ------------------------------------------------------------
	
	Method update(gameTime:Int)
	
		' TODO: This can probably be optimized...
		
		' Make a copy of the master screen list, To avoid confusion If
		' the process of updating one screen adds or removes others.
        Self.screensToUpdate.Clear()
		
		For Local screen:IGameScreen = EachIn Self.m_Screens
			Self.screensToUpdate.AddLast(screen)
		Next
		
		Local otherScreenHasFocus:Int	= False ' Not(Game.IsActive)
		Local coveredByOtherScreen:Int	= False
		
		' Loop as Long as there are screens waiting To be updated.
		While Self.screensToUpdate.Count() > 0
			
			' Pop screen & update
			Local currentScreen:IGameScreen	= IGameScreen(Self.screensToUpdate.RemoveLast())
			currentScreen.setIsCovered(coveredByOtherScreen)
			currentScreen.update(gameTime, otherScreenHasFocus, coveredByOtherScreen)
			
			' If screen is a popupm disable input for everything below
			' If currentScreen.State = IGameScreen.STATE_ACTIVE Or currentScreen.State = IGameScreen.STATE_TransitionOn Then
				
				' Update if first active screen
				If otherScreenHasFocus = False Then
					If currentScreen.inputEnabled() Then
						currentScreen.HandleInput()
					EndIf
					If currentScreen.isPopup() Then
						otherScreenHasFocus = True
					EndIf
				EndIf
				
				If currentScreen.IsPopup() Then
					coveredByOtherScreen = True
				End If				
			
		'	End If
			
		Wend
            
		' Print Debug Info?
		If Self.traceEnabled Then Self.traceScreens()
		
	End Method
	
	Method render(gameTime:Int)
		
		For Local screen:IGameScreen = EachIn Self.m_Screens
			If screen.IsHidden() = False Then
				screen.Render(gameTime)
			EndIf
		Next
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------
	
	Function Create:ScreenManager()
		Local this:ScreenManager = New ScreenManager
		Return this
	End Function
	
	
End Type
