' ------------------------------------------------------------------------------
' -- Pangolin.Resources
' -- 
' -- Handles resource management aspects of Pangolin. Allows programs to load
' -- resources (images, sounds, text strings) from files without having to 
' -- declare them explicitly in code.
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


Module pangolin.resources

SuperStrict

' -- Core files
Import "src/resource_manager.bmx"
Import "src/base_resource.bmx"

' -- Individual resource types
Import "src/resource_types/sound_resource.bmx"
Import "src/resource_types/image_resource.bmx"
Import "src/resource_types/font_resource.bmx"
Import "src/resource_types/animation_resource.bmx"
Import "src/resource_types/tilemap_resource.bmx"
Import "src/resource_types/tileset_resource.bmx"
' Import "src/resource_types/font_style_resource.bmx"
Import "src/resource_types/file_resource.bmx"

' -- Services
Import "src/services/resource_db_service.bmx"
