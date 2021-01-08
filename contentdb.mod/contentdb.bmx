' ------------------------------------------------------------------------------
' -- Pangolin.ContentDb -- contentdb.bmx
' --
' -- The ContentDb manages entity templates and other static, non-resource
' -- content. It allows entities to be defined in files and created from a
' -- template instead of done via code.
' --
' -- It's a bit weird, but it's pretty neat.
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

Module pangolin.contentdb

Import "src/content_db.bmx"
Import "src/entity_factory.bmx"
