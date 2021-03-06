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
local sqrt = math.sqrt

local super = tuple4
local class = { is_point4 = true }
local metatable = { __tostring = super.to_string }

-- a:set(number b, number y, number z, number w)
-- a:set(tuple4 b)
-- a:set(tuple3 b)
-- a:set()
function class.set(a, b, y, z, w)
  if b then
    if y then
      a[1] = b
      a[2] = y
      a[3] = z
      a[4] = w
      return a
    else
      a[1] = b[1]
      a[2] = b[2]
      a[3] = b[3]
      a[4] = b[4] or 1
      return a
    end
  else
    a[1] = 0
    a[2] = 0
    a[3] = 0
    a[4] = 0
    return a
  end
end

-- a:distance_squared(point4 b)
function class.distance_squared(a, b)
  local x = a[1] - b[1]
  local y = a[2] - b[2]
  local z = a[3] - b[3]
  local w = a[4] - b[4]
  return x * x + y * y + z * z + w * w
end

-- a:distance(point4 b)
function class.distance(a, b)
  local x = a[1] - b[1]
  local y = a[2] - b[2]
  local z = a[3] - b[3]
  local w = a[4] - b[4]
  return sqrt(x * x + y * y + z * z + w * w)
end

-- a:distance_l1(point4 b)
function class.distance_l1(a, b)
  local x = a[1] - b[1]
  local y = a[2] - b[2]
  local z = a[3] - b[3]
  local w = a[4] - b[4]
  if x < 0 then x = -x end
  if y < 0 then y = -y end
  if z < 0 then z = -z end
  if w < 0 then w = -w end
  return x + y + z + w
end

-- a:distance_linf(point4 b)
function class.distance_linf(a, b)
  local x = a[1] - b[1]
  local y = a[2] - b[2]
  local z = a[3] - b[3]
  local w = a[4] - b[4]
  if x < 0 then x = -x end
  if y < 0 then y = -y end
  if z < 0 then z = -z end
  if w < 0 then w = -w end
  if x > y then
    if z > w then
      if x > z then
        return x
      else
        return z
      end
    else
      if x > w then
        return x
      else
        return w
      end
    end
  else
    if z > w then
      if y > z then
        return y
      else
        return z
      end
    else
      if y > w then
        return y
      else
        return w
      end
    end
  end
end

-- a:project(point4 b)
function class.project(a, b)
  local d = b[4]
  a[1] = b[1] / d
  a[2] = b[2] / d
  a[3] = b[3] / d
  a[4] = 1
  return a
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

-- class(number b, number y, number z, number w)
-- class(tuple4 b)
-- class(tuple3 b)
-- class()
return setmetatable(class, {
  __index = super;
  __call = function (_, ...)
    return setmetatable(class.set({}, ...), metatable)
  end;
})
