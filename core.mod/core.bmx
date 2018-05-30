' ------------------------------------------------------------------------------
' -- pangolin.core - core.bmx
' --
' -- Contains the kernel and service model that all Pangolin games use.
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

Module pangolin.core
ModuleInfo "Pangolin.Core - Base classes for pangolin."

' Framework version and release information.
Import "framework_info.bmx"

' Import kernel code
Import "src/kernel/game_kernel.bmx"
Import "src/kernel/kernel_aware_interface.bmx"


' ------------------------------------------------------------
' -- FRAMEWORK INFORMATION AND CONFIGURATION
' ------------------------------------------------------------

''' <summary>Helper class for pangolin information.</summary>
Type PangolinFramework

   ''' <summary>Get the current version of the Pangolin framework.</summary>
	Function GetVersion:String()
		Return PANGOLIN_FRAMEWORK_VERSION
	End Function

	''' <summary>Get the release date for this version of the framework.</summary>
	Function GetReleaseDate:String()
		Return PANGOLIN_FRAMEWORK_DATE
	End Function

End Type
