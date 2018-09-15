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

Import pangolin.gfx

Import "screen_manager.bmx"

''' <summary>
''' A single screen within the game. Can be used as a background For other
''' screens or as a self-contained state.
'''
''' All screens have their own render group which requests can be added and
''' removed from. See `add and `remove` methods.
''' </summary>
Type GameScreen extends IGameScreen

	' -- Screen states (DEPRECATED).
	Const STATE_TransitionOn:Byte   = 1     '''< Screen is appearing
	Const STATE_TransitionOff:Byte  = 3     '''< Screen is disappearing

	Const STATE_TRANSITION_ON:Byte  = 1     '''< Screen is appearing
	Const STATE_ACTIVE:Byte         = 2     '''< Screen is running
	Const STATE_TRANSITION_OFF:Byte = 3     '''< Screen is disappearing
	Const STATE_HIDDEN:Byte         = 4     '''< Screen is not visible

	Field state:Byte                        '''< Current state of this screen

	' -- Internal info.
	Field _isPopup:Byte             = False '''< Is the screen a popup.
	Field _noFocus:Byte             = False
	Field _isExiting:Byte           = False

	Field _group:RenderGroup
	Field __renderer:SpriteRenderingService = Null


	' ------------------------------------------------------------
	' -- Querying the GameScreen
	' ------------------------------------------------------------

	''' <summary>Check if the screen is hidden.</summary>
	''' <return>True if screen is hidden, false if not.</return>
	Method isHidden:Byte()
		Return Self.State = STATE_HIDDEN
	End Method

	''' <summary>Check if the screen is a popup.</summary>
	''' <return>True if screen is a popup, false if not.</return>
	Method isPopup:Byte()
		Return Self._isPopup
	End Method


	' ------------------------------------------------------------
	' -- Managing renderable objects
	' ------------------------------------------------------------

	''' <summary>Add a render request to this screen's render group.</summary>
	''' <param name="obj">The request object to add.</param>
	''' <param name="name">Optional identifier for the request.</param>
	Method add(obj:AbstractRenderRequest, name:String = "")
		Self._group.add(obj, name)
	End Method

	''' <summary>Remove a render request from this screen's render group.</summary>
	''' <param name="obj">The request object to remove.</param>
	Method remove(obj:AbstractRenderRequest)
		Self._group.remove(obj)
	End Method

	''' <summary>Remove a render request from this screen's render group using its name.</summary>
	''' <param name="name">The name of the request to remove.</param>
	Method removeByName(name:String)
		Self._group.removeByName(name)
	End Method

	''' <summary>Get the render group associated with this screen.</summary>
	Method getRenderGroup:RenderGroup()
		Return Self._group
	End Method


	' ------------------------------------------------------------
	' -- Hooks
	' ------------------------------------------------------------

	''' <summary>Called after a screen has been added to the ScreenManager.</summary>
	Method afterAdd()

	End Method


	' ------------------------------------------------------------
	' -- Entry & Exiting
	' ------------------------------------------------------------

	''' <summary>
	''' Exit the screen. Once the (optional) transition has finished will
	''' remove the screen from the manager and remove all render requests.
	''' </summary>
	Method exitScreen()

		Self._isExiting	= True

		' Remove the screen from its parent screen manager.
		Self.getParentManager().RemoveScreen(Self)

		' Clear items from the renderer.
		Self._group.clear()
		Self.__renderer.remove(Self._group)
		Self._group = Null

		Self.leave()

	End Method


	' ------------------------------------------------------------
	' -- Updating & Rendering
	' ------------------------------------------------------------

	''' <summary>Update the current screen.</summary>
	''' <param name="delta">Delta time in millisecs</param>
	''' <param name="noFocus">Does this screen have focus?</param>
	''' <param name="covered">Is this screen covered?</param>
	Method update(delta:Float = 0, noFocus:Byte = False, covered:Byte = False)
		Self._noFocus = noFocus
	End Method

	''' <summary>Render the current screen</summary>
	''' <param name="delta">Delta time in milliseconds</param>
	Method render(delta:Float = 0)

	End Method


	' ------------------------------------------------------------
	' -- Transition Helpers
	' ------------------------------------------------------------

	''' <summary>Check if the current screen is transitioning on or off.</summary>
	''' <return>True if transitioning, false if not.</return>
	Method isTransitioning:Byte()
		If Self.state = GameScreen.STATE_TRANSITION_OFF Then Return True
		If Self.state = GameScreen.STATE_TRANSITION_ON Then Return True
	End Method


	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------

	Method New()
		Self._group	= New RenderGroup
	End Method

End Type
