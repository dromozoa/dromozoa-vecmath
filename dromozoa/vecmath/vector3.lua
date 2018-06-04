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

local tuple3 = require "dromozoa.vecmath.tuple3"

local rawset = rawset
local atan2 = math.atan2
local sqrt = math.sqrt

local super = tuple3
local class = {}
local metatable = { __tostring = super.to_string }

function class.cross(a, b, c)
  local bx = b[1]
  local by = b[2]
  local bz = b[3]
  local cx = c[1]
  local cy = c[2]
  local cz = c[3]
  a[1] = by * cz - bz * cy
  a[2] = bz * cx - bx * cz
  a[3] = bx * cy - by * cx
  return a
end

function class.normalize(a, b)
  local x = a[1]
  local y = a[2]
  local z = a[3]
  local d = sqrt(x * x + y * y + z * z)
  a[1] = x / d
  a[2] = y / d
  a[3] = z / d
  return a
end

function class.dot(a, b)
  return a[1] * b[1] + a[2] * b[2] + a[3] * b[3]
end

function class.length_squared(a)
  local x = a[1]
  local y = a[2]
  local z = a[3]
  return x * x + y * y + z * z
end

function class.length(a)
  local x = a[1]
  local y = a[2]
  local z = a[3]
  return sqrt(x * x + y * y + z * z)
end

function class.angle(a, b)
  local ax = a[1]
  local ay = a[2]
  local az = a[3]
  local bx = b[1]
  local by = b[2]
  local bz = b[3]
  local x = ay * bz - az * by
  local y = az * bx - ax * bz
  local z = ax * by - ay * bx
  local angle = atan2(sqrt(x * x + y * y + z * z), ax * bx + ay * by + az * bz)
  if angle < 0 then
    return -angle
  else
    return angle
  end
end

function metatable.__index(a, key)
  local value = class[key]
  if value then
    return value
  else
    return a[super.index[key]]
  end
end

function metatable.__newindex(a, key, value)
  rawset(a, super.index[key], value)
end

return setmetatable(class, {
  __index = super;
  __call = function (_, x, y, z)
    return setmetatable(class.set({}, x, y, z), metatable)
  end;
})
