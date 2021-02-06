' ------------------------------------------------------------------------------
' -- Pangolin.Entites -- entities.bmx
' --
' -- Base file for the Pangolin entity system module. Based on the Artemis
' -- entity framework.
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

Module pangolin.entities

Import brl.map
Import brl.reflection

Import pangolin.core

' -- Utilities.
Import "src/bit_storage.bmx"
Import "src/ttypeid_byte_map.bmx"

' -- Managers.
Import "src/component_type_manager.bmx"
Import "src/component_type.bmx"
Include "src/system_bit_manager.bmx"

' -- Core
Include "src/entity_component_mapper.bmx"
Include "src/entity_bag.bmx"
Include "src/entity.bmx"
Include "src/entity_component.bmx"
Include "src/exceptions.bmx"
Include "src/world.bmx"

' -- Managers
Include "src/managers/base_manager.bmx"
Include "src/managers/system_manager.bmx"
Include "src/managers/entity_manager.bmx"
Include "src/managers/tag_manager.bmx"
Include "src/managers/group_manager.bmx"

' -- Systems
Include "src/systems/entity_system.bmx"
Include "src/systems/entity_processing_system.bmx"
Include "src/systems/interval_entity_system.bmx"
Include "src/systems/interval_entity_processing_system.bmx"
Include "src/systems/delayed_entity_system.bmx"
Include "src/systems/delayed_entity_processing_system.bmx"
Include "src/systems/sweeper_entity_system.bmx"
Include "src/systems/sweeper_entity_processing_system.bmx"
Include "src/systems/initializer_entity_system.bmx"
Include "src/systems/initializer_entity_processing_system.bmx"

' -- Services
Include "src/services/game_entity_service.bmx"

' -- Query System
Include "src/entity_query.bmx"

