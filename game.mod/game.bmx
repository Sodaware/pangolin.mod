' ------------------------------------------------------------------------------
' -- pangolin.game
' --
' -- Main module for creating Pangolin games. Includes game specific code for
' -- game screen management.
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

Module pangolin.Game
ModuleInfo "Pangolin.Game - Game implementation for Pangolin."

' -- Services
Import "src/services/screen_manager_service/screen_manager_service.bmx"

' -- Game Core
Import "src/game_base.bmx"
