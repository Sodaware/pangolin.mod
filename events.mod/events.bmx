' ------------------------------------------------------------------------------
' -- Pangolin.Events
' -- 
' -- Contains the events service. Uses standard BlitzMax events, but removes
' -- the need to use brl.eventqueue (which has some dependencies that don't work
' -- in a server environment).
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

Module pangolin.events
ModuleInfo "Pangolin.Events - Event service."

' Service
Import "src/events_service.bmx"
Import "src/hooks.bmx"
