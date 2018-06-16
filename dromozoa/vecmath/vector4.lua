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

local tuple4 = require "dromozoa.vecmath.tuple4"

local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local acos = math.acos
local sqrt = math.sqrt

local super = tuple4
local class = { is_vector4 = true }
local metatable = { __tostring = super.to_string }

-- a:set(number b, number c, number d, number e)
-- a:set(tuple3 b)
-- a:set(tuple4 b)
-- a:set()
function class.set(a, b, c, d, e)
  if b then
    if c then
      a[1] = b
      a[2] = c
      a[3] = d
      a[4] = e
    else
      a[1] = b[1]
      a[2] = b[2]
      a[3] = b[3]
      a[4] = b[4] or 0
    end
  else
    a[1] = 0
    a[2] = 0
    a[3] = 0
    a[4] = 0
  end
  return a
end

-- a:length()
function class.length(a)
  local x = a[1]
  local y = a[2]
  local z = a[3]
  local w = a[4]
  return sqrt(x * x + y * y + z * z + w * w)
end

-- a:length_squared()
function class.length_squared(a)
  local x = a[1]
  local y = a[2]
  local z = a[3]
  local w = a[4]
  return x * x + y * y + z * z + w * w
end

-- a:dot(vector4 b)
function class.dot(a, b)
  return a[1] * b[1] + a[2] * b[2] + a[3] * b[3] + a[4] * b[4]
end

-- a:normalize(vector4 b)
-- a:normalize()
function class.normalize(a, b)
  if b then
    local x = b[1]
    local y = b[2]
    local z = b[3]
    local w = b[4]
    local d = sqrt(x * x + y * y + z * z + w * w)
    a[1] = x / d
    a[2] = y / d
    a[3] = z / d
    a[4] = w / d
  else
    local x = a[1]
    local y = a[2]
    local z = a[3]
    local w = a[4]
    local d = sqrt(x * x + y * y + z * z + w * w)
    a[1] = x / d
    a[2] = y / d
    a[3] = z / d
    a[4] = w / d
  end
  return a
end

-- a:angle(vector4 b)
function class.angle(a, b)
  local ax = a[1]
  local ay = a[2]
  local az = a[3]
  local aw = a[4]
  local bx = b[1]
  local by = b[2]
  local bz = b[3]
  local bw = b[4]
  local u = ax * bx + ay * by + az * bz + aw * bw
  local v = sqrt(ax * ax + ay * ay + az * az + aw * aw)
  local w = sqrt(bx * bx + by * by + bz * bz + bw * bw)
  return acos(u / v / w)
end

function metatable.__index(a, key)
  local value = class[key]
  if value then
    return value
  else
    return rawget(a, class.index[key])
  end
end

function metatable.__newindex(a, key, value)
  rawset(a, class.index[key], value)
end

-- class(number b, number c, number d, number e)
-- class(tuple3 b)
-- class(tuple4 b)
-- class()
return setmetatable(class, {
  __index = super;
  __call = function (_, ...)
    return setmetatable(class.set({}, ...), metatable)
  end;
})
