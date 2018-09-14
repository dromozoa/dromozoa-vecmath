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

local color4 = require "dromozoa.vecmath.color4"

local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable

-- a:to_string()
local function to_string(a)
  local x = a[1]
  local y = a[2]
  local z = a[3]
  local w = a[4]

  if w == 255 then
    if x % 17 == 0 and y % 17 == 0 and z % 17 == 0 then
      return ("#%01X%01X%01X"):format(x / 17, y / 17, z / 17)
    else
      return ("#%02X%02X%02X"):format(x, y, z)
    end
  else
    return ("rgba(%d,%d,%d,%.17g)"):format(x, y, z, w / 255)
  end
end

-- a:set_color4f(color4f b)
local function set_color4f(a, b)
  local bx = b[1] * 255
  local by = b[2] * 255
  local bz = b[3] * 255
  a[1] = bx - bx % 1
  a[2] = by - by % 1
  a[3] = bz - bz % 1
  a[4] = b[4] * 255
  return a
end

local super = color4
local class = {
  is_color4b = true;
  to_string = to_string;
  set_color4f = set_color4f;
}
local metatable = {
  __tostring = to_string;
  ["dromozoa.dom.is_serializable"] = true;
}

-- a:set(number b, number y, number z, number w)
-- a:set(color4f b)
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
      if b.is_color4f then
        return set_color4f(a, b)
      else
        a[1] = b[1]
        a[2] = b[2]
        a[3] = b[3]
        a[4] = b[4] or 255
        return a
      end
    end
  else
    a[1] = 0
    a[2] = 0
    a[3] = 0
    a[4] = 0
    return a
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

-- a:set(number b, number y, number z, number w)
-- a:set(color4f b)
-- a:set(tuple4 b)
-- a:set(tuple3 b)
-- a:set()
return setmetatable(class, {
  __index = super;
  __call = function (_, ...)
    return setmetatable(class.set({}, ...), metatable)
  end;
})
