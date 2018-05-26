' ------------------------------------------------------------------------------
' -- src/services/screen_manager_service/screen_manager.bmx
' --
' -- Handles the updating and rendering of GameScreens and
' -- their transitions.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import pangolin.core
Import sodaware.blitzmax_injection

Import "screen_manager.bmx"
Import "game_screen.bmx"

Type ScreenManagerService extends GameService ..
	{ implements = "update, render" }

	Field _screenManager:ScreenManager
	Field _kernelInfo:KernelInformationService	{ injectable }


	' ------------------------------------------------------------
	' -- Adding / Removing screens
	' ------------------------------------------------------------

	''' <summary>Add a screen to the manager and enter it.</summary>
	''' <param name="screen">The screen to add.</param>
	''' <param name="loadResources">If false, the screen will skip loading its resources.</param>
	Method addScreen(screen:GameScreen, loadResources:Byte = True)

		' Check screen is valid.
		Assert screen, "Cannot add a Null screen to the ScreenManager"

		' Inject any dependencies.
		DependencyInjector.addInjectableFields(screen)
		If DependencyInjector.hasDependencies(screen)
			For Local dependency:TTypeId = EachIn DependencyInjector.getDependencies(screen)
				DependencyInjector.inject(screen,  dependency, Self._kernelInfo.getService(dependency))
			Next
		End If

		' Add the screen's group to the renderer (if the renderer is present).
		Local renderer:SpriteRenderingService = Self.getRenderer()
		If renderer <> Null Then
			renderer.add(screen._group)
			screen.__renderer = renderer
		EndIf

		' Add screen to the screen manager.
		' This will load the screen's resources (unless `loadResources` is false) and call the `enter` method.
		Self._screenManager.addScreen(screen)

		' Call the `afterAdd` hook for the new screen.
		screen.afterAdd()

	End Method

	Method switchScreen(screen:GameScreen)
		Self.popScreen()
		Cls
		Self.addScreen(screen)
	End Method

	''' <summary>
	''' Removes a screen from the screen manager. You should normally
	''' use GameScreen.ExitScreen instead of calling this directly, so
	''' the screen can gradually transition off rather than just being
	''' instantly removed.
	''' </summary>
	Method removeScreen(screen:GameScreen)

		' Remove from the renderer
		Local renderer:SpriteRenderingService = Self.getRenderer()
		If renderer <> Null Then
			renderer.remove(screen.getRenderGroup(), True)
		EndIf

		' Remove from manager
		Self._screenManager.removeScreen(screen)

	End Method

	Method popScreen()
		Local screens:IGameScreen[] = Self.getScreens()
		Local screen:GameScreen     = GameScreen(screens[screens.Length - 1])
		Self.removeScreen(screen)
	End Method

	Method popScreenAndLeave()
		If Self.getScreens().Length = 0 Then Return

		Local screens:IGameScreen[] = Self.getScreens()
		Local screen:GameScreen     = GameScreen(screens[screens.Length - 1])
		screen.leave()
		Self.removeScreen(screen)
	End Method

	Method leaveAllScreens()
		For Local screen:GameScreen = EachIn Self.getScreens()
			screen.leave()
			Self.removeScreen(screen)
		Next
		Self.clearScreens()
	End Method

	Method clearScreens()
		self._screenManager.clearScreens()
	End Method

	''' <summary>
	''' Expose an array holding all the screens. We return a copy rather
	''' than the real master list, because screens should only ever be added
	''' or removed using the AddScreen and RemoveScreen methods.
	''' </summary>
	Method getScreens:GameScreen[]()
		Return GameScreen[](Self._screenManager.getScreens())
	End Method


	Method traceScreens()
		self._screenManager.traceScreens()
	End Method

	' ------------------------------------------------------------
	' -- Updating / Rendering
	' ------------------------------------------------------------

	Method update(delta:float)
		self._screenManager.update(delta)
	End Method

	Method render(delta:float)
		self._screenManager.render(delta)
	End Method

	''' <summary>Fetch the renderer.</summary>
	Method getRenderer:SpriteRenderingService()
		Return SpriteRenderingService(Self._kernelInfo.getService(TTypeId.ForName("SpriteRenderingService")))
	End Method


	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------

	Function Create:ScreenManagerService()
		Local this:ScreenManagerService = New ScreenManagerService
		Return this
	End Function

	Method New()
		Self._screenManager = New ScreenManager
		Self._addInjectableFields()
	End Method

End Type
