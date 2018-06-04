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

local rawset = rawset
local format = string.format

local function to_string(a)
  return format("%.17g, %.17g, %.17g\n%.17g, %.17g, %.17g\n%.17g, %.17g, %.17g",
      a[1], a[2], a[3],
      a[4], a[5], a[6],
      a[7], a[8], a[9])
end

local class = {
  index = {
    1, 2, 3, 4, 5, 6, 7, 8, 9,
    m11 = 1, m12 = 2, m13 = 3,
    m21 = 4, m22 = 5, m23 = 6,
    m31 = 7, m32 = 8, m33 = 9,
  };
  to_string = to_string;
}
local metatable = { __tostring = to_string }

function class.set_identity(a)
  a[1] = 1 a[2] = 0 a[3] = 0
  a[4] = 0 a[5] = 1 a[6] = 0
  a[7] = 0 a[8] = 0 a[9] = 1
  return a
end

function class.equals(a, b)
  return a and b
      and a[1] == b[1] and a[2] == b[2] and a[3] == b[3]
      and a[4] == b[4] and a[5] == b[5] and a[6] == b[6]
      and a[7] == b[7] and a[8] == b[8] and a[9] == b[9]
end

function class.epsilon_equals(a, b, epsilon)
  local v = a[1] - b[1] if v < 0 then v = -v end if v > epsilon then return false end
  local v = a[2] - b[2] if v < 0 then v = -v end if v > epsilon then return false end
  local v = a[3] - b[3] if v < 0 then v = -v end if v > epsilon then return false end
  local v = a[4] - b[4] if v < 0 then v = -v end if v > epsilon then return false end
  local v = a[5] - b[5] if v < 0 then v = -v end if v > epsilon then return false end
  local v = a[6] - b[6] if v < 0 then v = -v end if v > epsilon then return false end
  local v = a[7] - b[7] if v < 0 then v = -v end if v > epsilon then return false end
  local v = a[8] - b[8] if v < 0 then v = -v end if v > epsilon then return false end
  local v = a[9] - b[9] if v < 0 then v = -v end if v > epsilon then return false end
  return true
end

function metatable.__index(a, key)
  local value = class[key]
  if value then
    return value
  else
    return a[class.index[key]]
  end
end

function metatable.__newindex(a, key, value)
  rawset(a, class.index[key], value)
end

return setmetatable(class, {
  __call = function (_, m11, m12, m13, m21, m22, m23, m31, m32, m33)
    if m33 then
      return setmetatable({
        m11, m12, m13,
        m21, m22, m23,
        m31, m32, m33,
      }, metatable)
    end
    return setmetatable(class.set({}, m11, m12, m13, m21, m22, m23, m31, m32, m33), metatable)
  end;
})
