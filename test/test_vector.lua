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

local vector2 = require "dromozoa.vecmath.vector2"
local vector3 = require "dromozoa.vecmath.vector3"
local vector4 = require "dromozoa.vecmath.vector4"

assert(vector4{1,2,3}:equals{1,2,3,0})

local function check(class, data)
  local v1 = class(data[1])
  local v2 = class(data[2])

  assert(v1:length() == data.length)
  assert(v1:length_squared() == data.length_squared)
  assert(v1:dot(v2) == data.dot)
  assert(v2:dot(v1) == data.dot)
  assert(class():normalize(v1):equals(data.normalize))
  assert(class(v1):normalize():equals(data.normalize))
  assert(v1:angle(v2) == data.angle)
  assert(v2:angle(v1) == data.angle)

  if class == vector3 then
    assert(class():cross(v1, v2):equals(data.cross))
  end
end

local data = assert(loadfile "test/vector.lua")()
check(vector2, data.vector2)
check(vector3, data.vector3)
check(vector4, data.vector4)

local v1 = vector2(1, 0)
local v2 = vector2(1, 1)
assert(v1:cross(v2) == 1)

local v1 = vector2(4, 3):normalize()
local v2 = vector2(34, -12)
assert(v1:cross(v2) == -30)

local v = vector2(-1, -2)
assert(v:length_l1() == 3)
assert(v:length_linf() == 2)

local v = vector3(-1, -2, -3)
assert(v:length_l1() == 6)
assert(v:length_linf() == 3)

local v = vector4(-1, -2, -3, -4)
assert(v:length_l1() == 10)
assert(v:length_linf() == 4)
