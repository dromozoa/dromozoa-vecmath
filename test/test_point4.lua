-- Copyright (C) 2018 Tomoyuki Fujimori <moyu@dromozoa.com>
--
-- This file is part of dromozoa-vecmath.
--
-- dromozoa-vecmath is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- dromozoa-vecmath is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dromozoa-vecmath.  If not, see <http://www.gnu.org/licenses/>.

local point4 = require "dromozoa.vecmath.point4"

assert(point4{1,2,3}:equals{1,2,3,1})

assert(point4(1,2,3,4):distance_linf{0,0,0,0} == 4)
assert(point4(1,2,4,3):distance_linf{0,0,0,0} == 4)
assert(point4(1,3,2,4):distance_linf{0,0,0,0} == 4)
assert(point4(1,3,4,2):distance_linf{0,0,0,0} == 4)
assert(point4(1,4,2,3):distance_linf{0,0,0,0} == 4)
assert(point4(1,4,3,2):distance_linf{0,0,0,0} == 4)
assert(point4(2,1,3,4):distance_linf{0,0,0,0} == 4)
assert(point4(2,1,4,3):distance_linf{0,0,0,0} == 4)
assert(point4(2,3,1,4):distance_linf{0,0,0,0} == 4)
assert(point4(2,3,4,1):distance_linf{0,0,0,0} == 4)
assert(point4(2,4,1,3):distance_linf{0,0,0,0} == 4)
assert(point4(2,4,3,1):distance_linf{0,0,0,0} == 4)
assert(point4(3,1,2,4):distance_linf{0,0,0,0} == 4)
assert(point4(3,1,4,2):distance_linf{0,0,0,0} == 4)
assert(point4(3,2,1,4):distance_linf{0,0,0,0} == 4)
assert(point4(3,2,4,1):distance_linf{0,0,0,0} == 4)
assert(point4(3,4,1,2):distance_linf{0,0,0,0} == 4)
assert(point4(3,4,2,1):distance_linf{0,0,0,0} == 4)
assert(point4(4,1,2,3):distance_linf{0,0,0,0} == 4)
assert(point4(4,1,3,2):distance_linf{0,0,0,0} == 4)
assert(point4(4,2,1,3):distance_linf{0,0,0,0} == 4)
assert(point4(4,2,3,1):distance_linf{0,0,0,0} == 4)
assert(point4(4,3,1,1):distance_linf{0,0,0,0} == 4)
assert(point4(4,3,2,1):distance_linf{0,0,0,0} == 4)

assert(point4():project{2,3,4,2}:equals{1,1.5,2,1})

local data = assert(loadfile "test/point4d.lua")()

local p = point4()
local p1 = point4(data[1])
local p2 = point4(data[2])

assert(p1:distance_squared(p2) == data.distance_squared)
assert(p1:distance(p2) == data.distance)
assert(p1:distance_l1(p2) == data.distance_l1)
assert(p1:distance_linf(p2) == data.distance_linf)
