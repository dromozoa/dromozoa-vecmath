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
local sqrt = math.sqrt

local super = tuple3
local class = {}
local metatable = { __tostring = super.to_string }

function class.distance_squared(a, b)
  local x = a[1] - b[1]
  local y = a[2] - b[2]
  local z = a[3] - b[3]
  return x * x + y * y + z * z
end

function class.distance(a, b)
  local x = a[1] - b[1]
  local y = a[2] - b[2]
  local z = a[3] - b[3]
  return sqrt(x * x + y * y + z * z)
end

function class.distance_l1(a, b)
  local x = a[1] - b[1]
  local y = a[2] - b[2]
  local z = a[3] - b[3]
  if x < 0 then x = -x end
  if y < 0 then y = -y end
  if z < 0 then z = -z end
  return x + y + z
end

function class.distance_linf(a, b)
  local x = a[1] - b[1]
  local y = a[2] - b[2]
  local z = a[3] - b[3]
  if x < 0 then x = -x end
  if y < 0 then y = -y end
  if z < 0 then z = -z end
  if x > y then
    if x > z then
      return x
    else
      return z
    end
  else
    if y > z then
      return y
    else
      return z
    end
  end
end

function class.project(a, b)
  local w = b[4]
  a[1] = b[1] / w
  a[2] = b[2] / w
  a[3] = b[3] / w
  return a
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
  __call = function (_, ...)
    return setmetatable(class.set({}, ...), metatable)
  end;
})
