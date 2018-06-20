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

local point2 = require "dromozoa.vecmath.point2"
local point3 = require "dromozoa.vecmath.point3"
local point4 = require "dromozoa.vecmath.point4"

local epsilon = 1e-9

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
assert(point3():project{2,3,4,2}:equals{1,1.5,2})
assert(point3():project{2,3,2}:equals{1,1.5,1})
assert(point2():project{2,3,2}:equals{1,1.5})

local function check(class, data)
  local p1 = class(data[1])
  local p2 = class(data[2])

  assert(p1:distance_squared(p2) == data.distance_squared)
  assert(p1:distance(p2) == data.distance)
  assert(p1:distance_l1(p2) == data.distance_l1)
  assert(p1:distance_linf(p2) == data.distance_linf)

  if class == point3 then
    assert(class():project(data[3]):epsilon_equals(data.project, epsilon))
  elseif class == point4 then
    assert(class():project(p1):epsilon_equals(data.project, epsilon))
  end
end

local data = assert(loadfile "test/point.lua")()
check(point2, data.point2)
check(point3, data.point3)
check(point4, data.point4)
