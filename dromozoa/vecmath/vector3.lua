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

local atan2 = math.atan2
local sqrt = math.sqrt

local super = tuple3
local super_metatable = getmetatable(super())
local class = {}
local metatable = {
  __tostring = super_metatable.__tostring;
  __newindex = super_metatable.__newindex;
}

function class.cross(a, b, c)
  -- alias-safety
  local x = b[2] * c[3] - b[3] * c[2]
  local y = b[3] * c[1] - b[1] * c[3]
  local z = b[1] * c[2] - b[2] * c[1]
  a[1] = x
  a[2] = y
  a[3] = z
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

function class.length_squared()
  local x = a[1]
  local y = a[2]
  local z = a[3]
  return x * x + y * y + z * z
end

function class.length()
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
  local cx = ay * bz - az * by
  local cy = az * bx - ax * bz
  local cz = ax * by - ay * bx
  local cross = sqrt(cx * cx + cy * cy + cz * cz)
  local dot = ax * bx + ay * by + az * bz
  local angle = atan2(cross, dot)
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
    return a[class.index[key]]
  end
end

return setmetatable(class, {
  __index = super;
  __call = function (_, x, y, z)
    return setmetatable(class.set({}, x, y, z), metatable)
  end;
})
