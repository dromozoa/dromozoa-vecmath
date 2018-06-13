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
local atan2 = math.atan2
local sqrt = math.sqrt

local function set_quat4(a, b)
  local x = b[1]
  local y = b[2]
  local z = b[3]
  local d = sqrt(x * x + y * y + z * z)
  if d == 0 then
    a[1] = 0
    a[2] = 1
    a[3] = 0
    a[4] = 0
  else
    a[1] = x / d
    a[2] = y / d
    a[3] = z / d
    a[4] = 2 * atan2(d, b[4])
  end
  return a
end

local function set_matrix3(a, b)
  local x = b[8] - b[6]
  local y = b[3] - b[7]
  local z = b[4] - b[2]
  local d = sqrt(x * x + y * y + z * z)
  if d == 0 then
    a[1] = 0
    a[2] = 1
    a[3] = 0
    a[4] = 0
  else
    a[1] = x / d
    a[2] = y / d
    a[3] = z / d
    a[4] = atan2(d, b[1] + b[5] + b[9] - 1)
  end
  return a
end

local class = {
  is_axis_angle4 = true;
  index = {
    1, 2, 3, 4,
    x = 1, y = 2, z = 3, angle = 4,
  };
  equals = tuple4.equals;
  epsilon_equals = tuple4.epsilon_equals;
  set_quat4 = set_quat4;
  set_matrix3 = set_matrix3;
}
local metatable = { __tostring = tuple4.to_string }

-- a:set(number b, number c, number d, number e)
-- a:set(vector3 b, number c)
-- a:set(quat4 b)
-- a:set(axis_angle4 b)
-- a:set(matrix3 b)
-- a:set(matrix4 b)
function class.set(a, b, c, d, e)
  if b then
    if c then
      if d then
        a[1] = b
        a[2] = c
        z[3] = d
        a[4] = e
      else
        a[1] = b[1]
        a[2] = b[2]
        a[3] = b[3]
        a[4] = c
      end
    else
      local n = #b
      if n == 4 then
        if b.is_quat4 then
          return set_quat4(a, b)
        else
          a[1] = b[1]
          a[2] = b[2]
          a[3] = b[3]
          a[4] = b[4]
        end
      elseif n == 9 then
        return set_matrix3(a, b)
      else
        -- TODO impl set matrix4
      end
    end
  else
    a[1] = 0
    a[2] = 0
    a[3] = 1
    a[4] = 0
  end
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

-- class(number b, number c, number d, number e)
-- class(vector3 b, number c)
-- class(axis_angle4 b)
-- class()
return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(class.set({}, ...), metatable)
  end;
})
