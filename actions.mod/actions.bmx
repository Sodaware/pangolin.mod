' ------------------------------------------------------------------------------
' -- Pangolin.Actions -- actions.bmx
' --
' -- Base file for the Pangolin background-actions module.
' --
' -- A background action is anything that needs to be running whilst other stuff
' -- is going on, instead of blocking input or game execution. This could be a
' -- camera effect, moving a set of entities or anything else.
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

Module pangolin.actions

' Default actions.
Import "src/actions/parallel_action.bmx"
Import "src/actions/sequential_action.bmx"
Import "src/actions/callback_action.bmx"
Import "src/actions/wait_action.bmx"

' Main service.
Import "src/services/background_actions_service.bmx"
