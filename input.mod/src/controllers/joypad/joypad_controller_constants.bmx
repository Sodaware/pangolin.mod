' ------------------------------------------------------------------------------
' -- src/managers/joypad/joypad_controller_constants.bmx
' --
' -- Constants for working with joypad buttons. These make code more readable
' -- but aren't required.
' --
' -- Two controller types are currently supported:
' --   - XBox One controller
' --   - Retro-Bit Sega Mega Drive/Genesis controller
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2022 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------

SuperStrict

' ------------------------------------------------------------
' -- XBox One
' ------------------------------------------------------------

Const XBOX_BUTTON_A:Byte        = 0
Const XBOX_BUTTON_B:Byte        = 1
Const XBOX_BUTTON_X:Byte        = 2
Const XBOX_BUTTON_Y:Byte        = 3
Const XBOX_BUTTON_LB:Byte       = 4
Const XBOX_BUTTON_RB:Byte       = 5
Const XBOX_BUTTON_START:Byte    = 7
Const XBOX_BUTTON_SELECT:Byte   = 6

?win32
Const XBOX_BUTTON_LS_CLICK:Byte = 8
Const XBOX_BUTTON_RS_CLICK:Byte = 9
?linux
Const XBOX_BUTTON_LS_CLICK:Byte = 9
Const XBOX_BUTTON_RS_CLICK:Byte = 10
?macos
Const XBOX_BUTTON_LS_CLICK:Byte = 8
Const XBOX_BUTTON_RS_CLICK:Byte = 9
?

' joyhat - windows only?
Const XBOX_BUTTON_DPAD_UP:Float    = 0
Const XBOX_BUTTON_DPAD_DOWN:Float  = 0.5
Const XBOX_BUTTON_DPAD_LEFT:Float  = 0.75
Const XBOX_BUTTON_DPAD_RIGHT:Float = 0.25


' ------------------------------------------------------------
' -- Mea Drive/Genesis
' ------------------------------------------------------------

Const MEGADRIVE_BUTTON_A:Byte     = 2
Const MEGADRIVE_BUTTON_B:Byte     = 1
Const MEGADRIVE_BUTTON_C:Byte     = 7
Const MEGADRIVE_BUTTON_X:Byte     = 3
Const MEGADRIVE_BUTTON_Y:Byte     = 0
Const MEGADRIVE_BUTTON_Z:Byte     = 6
Const MEGADRIVE_BUTTON_LB:Byte    = 4
Const MEGADRIVE_BUTTON_RB:Byte    = 5
Const MEGADRIVE_BUTTON_START:Byte = 9
Const MEGADRIVE_BUTTON_MODE:Byte  = 8
