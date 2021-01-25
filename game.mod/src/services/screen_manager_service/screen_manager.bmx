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

Import brl.reflection

Include "igame_screen.bmx"

Type ScreenManager
	Field _screens:IGameScreen[]
	Field screensToUpdate:IGameScreen[]
	Field traceEnabled:Byte


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
		Assert screen <> Null, "Cannot add a null screen"

		' Setup the newly added screen.
		screen.setIsExiting(False)
		screen.setParentManager(Self)

		' Load resources (unless skipped)
		If loadResources Then
			screen.loadResources()
		EndIf

		' Add to the list of screens and enter.
		Self._screens = Self._screens[..Self._screens.length + 1]
		Self._screens[Self._screens.length - 1] = screen

		Self._enterScreen(screen)
	End Method

	''' <summary>Pop the last screen added and exit it.</summary>
	Method popScreen:IGameScreen()
		If Self._screens.length = 0 Then Return Null

		Local screen:IGameScreen = Self._screens[Self._screens.length - 1]
		Self._screens = Self._screens[..Self._screens.length - 1]

		screen.exitScreen()

		Return screen
	End Method

	''' <summary>
	''' Removes a screen from the screen manager.
	'''
	''' You should normally use IGameScreen.ExitScreen instead of calling this
	''' directly, so the screen can gradually transition off rather than just
	''' being instantly removed.
	''' </summary>
	Method removeScreen:IGameScreen(screen:IGameScreen)
		' Free resources for the screen
		screen.freeResources()

		' Remove from lists.
		Self._screens        = Self._removeFromArray(Self._screens, screen)
		Self.screensToUpdate = Self._removeFromArray(Self.screensToUpdate, screen)

		Return screen
	End Method

	''' <summary>
	''' Clears all screens from the current list of screens.
	''' </summary>
	Method clearScreens()
		For Local screen:IGameScreen = EachIn Self._screens
			Self.removeScreen(screen)
		Next
	End Method

	''' <summary>
	''' Expose an array holding all the screens.
	'''
	''' We return a copy rather than the real master list, because screens
	''' should only ever be added or removed using the AddScreen and
	''' RemoveScreen methods.
	''' </summary>
	Method getScreens:IGameScreen[]()
		Return Self._screens
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
	' -- Updating / Rendering
	' ------------------------------------------------------------

	Method update(delta:Float)

		' Make a copy of the master screen list. This prevents issues if screens
		' are added or removed during the update cycle.
		Self.screensToUpdate = Self._screens[..]

		Local otherScreenHasFocus:Byte  = False
		Local coveredByOtherScreen:Byte = False

		' Loop as long as there are screens waiting to be updated.
		While Self.screensToUpdate.length > 0
			' Pop screen & update.
			Local currentScreen:IGameScreen = Self.screensToUpdate[Self.screensToUpdate.length - 1]
			Self.screensToUpdate = Self.screensToUpdate[..Self.screensToUpdate.length - 1]

			currentScreen.setIsCovered(coveredByOtherScreen)
			currentScreen.update(delta, otherScreenHasFocus, coveredByOtherScreen)

			' If screen is a popup, disable input for everything below
			' Update if first active screen
			If otherScreenHasFocus = False Then
				If currentScreen.inputEnabled() And currentScreen.isVisible() Then
					currentScreen.handleInput()
				EndIf

				If currentScreen.isPopup() Then
					otherScreenHasFocus = True
				EndIf
			EndIf

			If currentScreen.isPopup() Then
				coveredByOtherScreen = True
			End If

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

	Method _removeFromArray:IGameScreen[](arr:IGameScreen[], toRemove:IGameScreen)
		Local newList:IGameScreen[]
		Local i:Int

		For Local s:IGameScreen = EachIn arr
			If s <> toRemove Then
				newList    = newList[..i + 1]
				newList[i] = s
				i :+ 1
			EndIf
		Next

		Return newList
	End Method


	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------

	Function Create:ScreenManager()
		Local this:ScreenManager = New ScreenManager
		Return this
	End Function

End Type
