' ------------------------------------------------------------------------------
' -- src/services/screen_manager_service/igame_screen.bmx
' --
' -- Base type for game screens to inherit from. Done this
' -- way to prevent circular dependencies between GameScreen
' -- and ScreenManager.
' --
' -- This file is INCLUDED in the ScreenManager file.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


 Type IGameScreen Abstract
	
	Field _parentManager:ScreenManager
	Field _isExiting:Byte
	Field _isCovered:Byte
	Field _inputEnabled:Byte = True
	
	
	' ------------------------------------------------------------
	' -- Setters / Getters
	' ------------------------------------------------------------
	
	Method setIsExiting(exiting:byte = false)
		self._isExiting = exiting
	End Method

	Method setIsCovered(covered:Byte = false)
		self._isCovered = covered
	End Method

	''' <summary>Check if the screen is hidden.</summary>
	Method isHidden:Int() Abstract
	Method isPopup:Int() Abstract
	Method inputEnabled:Byte()
		Return Self._inputEnabled
	End Method
	
	Method isCovered:byte()
		return self._isCovered
	End Method
	
	Method isExiting:byte()
		Return Self._isExiting
	End Method
	
	' [todo] - Rename this to "setManager"
	
	Method setParent(parent:ScreenManager)
		Self._parentManager = parent
	End Method
	
	Method getParent:ScreenManager()
		Return Self._parentManager
	End Method
	
	
	' ------------------------------------------------------------
	' -- Resource Management
	' ------------------------------------------------------------
	
	Method loadResources()	; End Method
	Method freeResources()	; End Method
	
	
	' ------------------------------------------------------------
	' -- Entry & Exiting
	' ------------------------------------------------------------

	Method exitScreen() Abstract
	
	Method enter()			; End Method
	Method leave()			; End Method
	
	
	' ------------------------------------------------------------
	' -- Input Handling
	' ------------------------------------------------------------
	
	Method disableInput()
		Self._inputEnabled = False
	End Method
	
	Method enableInput()
		Self._inputEnabled = True
	End Method
	
	Method handleInput()	; End Method
	

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
	
	''' <summary>Update the current screen.</summary>
	''' <param name="delta">Delta time in millisecs</param>
	''' <param name="noFocus">Does this screen have focus?</param>
	''' <param name="covered">Is this screen covered</param>
	Method update(delta:Float = 0, noFocus:Int = False, covered:Int = False) Abstract
	Method render(delta:Float = 0) Abstract
	
End Type
