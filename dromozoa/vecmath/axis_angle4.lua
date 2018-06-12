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
local type = type

local super = tuple4
local class = {
  index = {
    1, 2, 3, 4,
    x = 1, y = 2, z = 3, angle = 4,
  };
  equals = super.equals;
  epsilon_equals = super.epsilon_equals;
}
local metatable = { __tostring = super.to_string }

-- number, number, number, number
-- axis_angle4
-- vector3, number
-- matrix4
-- matrix3
-- quat4

function class.set(a, x, y, z, angle)
  if x then
    if y then
      if z then
        a[1] = x
        a[2] = y
        z[3] = z
        a[4] = angle
      else
        a[1] = x[1]
        a[2] = x[2]
        a[3] = x[3]
        a[4] = y
      end
    else
      a[1] = x[1]
      a[2] = x[2]
      a[3] = x[3]
      a[4] = x[4]
    end
  else
    a[1] = 0
    a[2] = 0
    a[3] = 1
    a[4] = 0
  end
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

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(class.set({}, ...), metatable)
  end;
})
