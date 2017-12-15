' ------------------------------------------------------------------------------
' -- gfx.bmx
' -- 
' -- Main module for the Pangolin graphics system.
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


Module pangolin.gfx

SuperStrict

Import brl.graphics
Import brl.retro


' -- Main helper class
Import "pangolin_gfx.bmx"

' -- Services
Import "src/services/sprite_rendering_service.bmx"
Import "src/services/sprite_behaviour_service.bmx"

' -- Graphics drivers
Import "src/driver/graphics_manager.bmx"

' -- Import renderer & screen objects
Import "src/renderer/render_camera.bmx"
Import "src/renderer/render_queue.bmx"
Import "src/renderer/screen_objects/render_group.bmx"
Import "src/renderer/screen_objects/clipped_render_group.bmx"
Import "src/renderer/screen_objects/tile_image_request.bmx"
Import "src/renderer/screen_objects/image_sprite.bmx"
Import "src/renderer/screen_objects/text_render_request.bmx"
Import "src/renderer/screen_objects/rectangle_render_request.bmx"
Import "src/renderer/screen_objects/progress_bar_render_request.bmx"

' -- Import behaviours
Import "src/behaviour/sequential_sprite_behaviour.bmx"
Import "src/behaviour/parallel_sprite_behaviour.bmx"
Import "src/behaviour/move_sprite_behaviour.bmx"
Import "src/behaviour/pixel_move_sprite_behaviour.bmx"
Import "src/behaviour/physics_move_sprite_behaviour.bmx"
Import "src/behaviour/hide_sprite_behaviour.bmx"
Import "src/behaviour/show_sprite_behaviour.bmx"
Import "src/behaviour/fade_sprite_behaviour.bmx"
Import "src/behaviour/pause_behaviour.bmx"


' -- Helper functions
Import "src/util/hex_util.bmx"
Import "src/util/graphics_util.bmx"
Import "src/util/render_state.bmx"
Import "src/util/scale_image.bmx"
Import "src/util/position.bmx"
