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

	' TODO: Change to "IGameScreenCollection"?
	Field _screens:TList        = New TList
	Field screensToUpdate:TList = New TList

	Field traceEnabled:Byte     = False


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
	Method addScreen(screen:IGameScreen, loadResources:Byte = True)

		Assert screen <> null, "Cannot add a null screen"

		' Setup the newly added screen.
		screen.setIsExiting(False)
		screen.setParentManager(Self)

		' Load resources (unless skipped)
		If loadResources Then
			screen.loadResources()
		EndIf

		' Add to the list of active screens and enter.
		Self._screens.AddLast(screen)
		Self._enterScreen(screen)

	End Method

	Method popScreen:IGameScreen()
		IGameScreen(Self._screens.Last()).exitScreen()
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
		Self._screens.Remove(screen)
		Self.screensToUpdate.Remove(screen)

		Return screen

	End Method

	''' <summary>
	''' Clears all screens from the current list of screens.
	''' </summary>
	Method clearScreens()

		For Local screen:IGameScreen = EachIn Self._screens
			screen.freeResources()
			Self._screens.remove(screen)
			Self.screensToUpdate.remove(screen)
		Next

		Self._screens.Clear()

	End Method

	''' <summary>
	''' Expose an array holding all the screens. We return a copy rather
	''' than the real master list, because screens should only ever be added
	''' or removed using the AddScreen and RemoveScreen methods.
	''' </summary>
	Method getScreens:IGameScreen[]()
		Return IGameScreen[](Self._screens.ToArray())
	End Method

	Method _enterScreen(screen:IGameScreen)
		screen.beforeEnter()
		screen.enter()
		screen.afterEnter()
	End Method


	' ------------------------------------------------------------
	' -- Debug Helpers
	' ------------------------------------------------------------

	Method traceScreens()

		DebugLog "ScreenManager.TraceScreens {"
		For Local screen:IGameScreen = EachIn Self._screens
			Local t:TTypeId = TTypeId.ForObject(screen)
			DebugLog "    " + t.Name()
		Next
		DebugLog "}"

	End Method


	' ------------------------------------------------------------
	' -- Content Loading / Unloading
	' ------------------------------------------------------------

	Method loadContent()
		RuntimeError "ScreenManager.loadContent -- Method is deprecated"
	End Method


	' ------------------------------------------------------------
	' -- Updating / Rendering
	' ------------------------------------------------------------

	Method update(gameTime:Int)

		' TODO: This can probably be optimized...

		' Make a copy of the master screen list, To avoid confusion If
		' the process of updating one screen adds or removes others.
		Self.screensToUpdate.clear()

		For Local screen:IGameScreen = EachIn Self._screens
			Self.screensToUpdate.addLast(screen)
		Next

		Local otherScreenHasFocus:Byte  = False
		Local coveredByOtherScreen:Byte = False

		' Loop as long as there are screens waiting to be updated.
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

	' TODO: Might even remove this, seeing as it's all handled by the renderer now...
	Method render(delta:Float)

		For Local screen:IGameScreen = EachIn Self._screens
			If screen.isHidden() = False Then
				screen.render(delta)
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
