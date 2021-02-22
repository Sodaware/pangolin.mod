' ------------------------------------------------------------------------------
' -- pangolin.gfx_actions -- gfx_actions.bmx
' --
' -- Background actions for graphical effects. These are split from the main
' -- module so that it doesn't require gfx libraries to run.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2021 Phil Newton
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

Module pangolin.gfx_actions

Import pangolin.actions
Import pangolin.gfx

Import "src/actions/fade_screen_action.bmx"
Import "src/actions/fade_sprite_action.bmx"
Import "src/actions/shake_camera_action.bmx"
