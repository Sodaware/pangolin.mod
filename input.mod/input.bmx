' ------------------------------------------------------------------------------
' -- Pangolin.Input -- input.bmx
' -- 
' -- Contains service and utilities for the input manager. Use this to get
' -- input from the user in a flexible, customizable way (keyboard or gamepad).
' -- 
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- This library is free software; you can redistribute it and/or modify
' -- it under the terms of the GNU Lesser General Public License as
' -- published by the Free Software Foundation; either version 3 of the
' -- License, or (at your option) any later version.
' --
' -- This library is distributed in the hope that it will be useful,
' -- but WITHOUT ANY WARRANTY; without even the implied warranty of
' -- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
' -- GNU Lesser General Public License for more details.
' -- 
' -- You should have received a copy of the GNU Lesser General Public
' -- License along with this library (see the file COPYING for more
' -- details); If not, see <http://www.gnu.org/licenses/>.
' ------------------------------------------------------------------------------


SuperStrict

Module pangolin.input

Import "src/services/virtual_input_service.bmx"

Import "src/controllers/keyboard/keyboard_controller_input.bmx"
Import "src/controllers/joypad/joypad_controller_input.bmx"
