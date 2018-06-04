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

local vector3 = require "dromozoa.vecmath.vector3"

local verbose = os.getenv "VERBOSE" == "1"

local v1 = vector3(3,4,1)
local v2 = vector3(3,7,5)
local v3 = vector3()

assert(v1:dot(v2) == 42)
assert(v3:cross(v1, v2) :equals {13,-12,9})
assert(v1:cross(v1, v2) :equals {13,-12,9})

local v = vector3(3,7,5)
assert(v:length_squared() == 83)
assert(v:length() == math.sqrt(83))
v:normalize()
assert(v.x == 3 / math.sqrt(83))
assert(v.y == 7 / math.sqrt(83))
assert(v.z == 5 / math.sqrt(83))

local v1 = vector3(1,2,3)
local v2 = vector3(3,4,5)
local angle = v1:angle(v2) * 180 / math.pi
if verbose then
  print(angle)
end
assert(10.67069 < angle and angle < 10.67070)

local angle = v2:angle(v1) * 180 / math.pi
assert(10.67069 < angle and angle < 10.67070)
