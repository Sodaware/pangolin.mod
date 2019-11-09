' ------------------------------------------------------------------------------
' -- src/services/screen_manager_service/igame_screen.bmx
' --
' -- Base type that GameScreen inherits from.
' --
' -- This file is INCLUDED in the ScreenManager file.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------

''' <summary>Base screen that GameScreen extends. Use `GameScreen`, not this.</summary>
''' <remarks>
''' This was handled by a separate class (rather than in `GameScreen`) to prevent
''' circular dependencies between GameScreen and ScreenManager.
''' </remarks>
Type IGameScreen Abstract

	Field _parentManager:ScreenManager
	Field _isExiting:Byte
	Field _isCovered:Byte
	Field _inputEnabled:Byte = True


	' ------------------------------------------------------------
	' -- Setters / Getters
	' ------------------------------------------------------------

	''' <summary>Set the "isExiting" property.</summary>
	''' <param name="exiting">True if the screen is exiting, false if not.</param>
	Method setIsExiting(exiting:Byte = False)
		Self._isExiting = exiting
	End Method

	''' <summary>Set the "isCovered" property.</summary>
	''' <param name="covered">True if the screen is covered, false if not.</param>
	Method setIsCovered(covered:Byte = False)
		Self._isCovered = covered
	End Method

	''' <summary>Check if the screen is hidden.</summary>
	Method isHidden:Byte() Abstract

	''' <summary>Check if the screen is a popup.</summary>
	Method isPopup:Byte() Abstract

	''' <summary>Check if the screen is processing input.</summary>
	Method inputEnabled:Byte()
		Return Self._inputEnabled
	End Method

	''' <summary>Check if the screen is covered.</summary>
	Method isCovered:byte()
		return self._isCovered
	End Method

	''' <summary>Check if the screen is exiting.</summary>
	Method isExiting:byte()
		Return Self._isExiting
	End Method

	''' <summary>Set the ScreenManager this screen belongs to.</summary>
	Method setParentManager(parent:ScreenManager)
		Self._parentManager = parent
	End Method

	''' <summary>Get the ScreenManager this screen belongs to.</summary>
	Method getParentManager:ScreenManager()
		Return Self._parentManager
	End Method


	' ------------------------------------------------------------
	' -- Resource Management
	' ------------------------------------------------------------

	''' <summary>
	''' Load resources required by the screen. Should be overridden by
	''' child screen types.
	''' </summary>
	Method loadResources()

	End Method

	''' <summary>
	''' Free any resources loaded by the screen. Should be overridden
	''' by child screen types.
	''' </summary>
	Method freeResources()

	End Method


	' ------------------------------------------------------------
	' -- Entry & Exiting
	' ------------------------------------------------------------

	Method exitScreen() Abstract

	'''' <summary>Called when the screen is entered (after loading).</summary>
	Method enter()
	End Method

	'''' <summary>Called when the screen is exited (after resources are freed).</summary>
	Method leave()
	End Method

	''' <summary>Called just before the screen is entered.</summary>
	Method beforeEnter()
	End Method

	''' <summary>Called just after the screen is entered.</summary>
	Method afterEnter()
	End Method

	''' <summary>Called just before the screen is exited.</summary>
	Method beforeLeave()
	End Method

	''' <summary>Called just after the screen is exited.</summary>
	Method afterLeave()
	End Method


	' ------------------------------------------------------------
	' -- Input Handling
	' ------------------------------------------------------------

	''' <summary>Disable input processing for this screen.</summary>
	Method disableInput()
		Self._inputEnabled = False
	End Method

	''' <summary>Disable input processing for this screen.</summary>
	Method enableInput()
		Self._inputEnabled = True
	End Method

	''' <summary>
	''' Process input specific to this screen.
	'''
	''' Input processing can be disabled by calling `disableInput`.
	''' </summary>
	Method handleInput()
	End Method


	' ------------------------------------------------------------
	' -- Screen Management
	' ------------------------------------------------------------

	''' <summary>
	''' Push another screen onto the global stack. Use this to put one screen
	''' on top of another, such as a menu popup.
	''' </summary>
	Method pushScreen(screen:IGameScreen)
		Self._parentManager.addScreen(screen)
	End Method

	''' <summary>
	''' Remove the current screen and replace it with a new one.
	''' </summary>
	Method switchScreen(screen:IGameScreen)
		Self._parentManager.switchScreen(screen)
	End Method


	' ------------------------------------------------------------
	' -- Updating & Rendering
	' ------------------------------------------------------------

	''' <summary>Update the screen.</summary>
	''' <param name="delta">Delta time since last update (in millisecs).</param>
	''' <param name="noFocus">Does this screen have focus?</param>
	''' <param name="covered">Is this screen covered</param>
	Method update(delta:Float = 0, noFocus:Byte = False, covered:Byte = False) Abstract

	''' <summary>Render the screen.</summary>
	''' <param name="delta">Delta time since last render (in millisecs).</param>
	Method render(delta:Float = 0) Abstract

End Type
