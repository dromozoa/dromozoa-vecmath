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

local point2 = require "dromozoa.vecmath.point2"
local vector2 = require "dromozoa.vecmath.vector2"

local setmetatable = setmetatable
local type = type

local class = { is_arcto = true }
local metatable = { __index = class }

-- self:set(number a, number b, number c, boolean d, boolean e, number f, number g)
-- self:set(number a, number b, number c, boolean d, boolean e, tuple2 f)
-- self:set(tuple2 a, number b, boolean c, boolean d, number e, number f)
-- self:set(tuple2 a, number b, boolean c, boolean d, tuple2 e)
-- self:set(arcto a)
-- self:set()
function class:set(a, b, c, d, e, f, g)
  local r = self[1]
  local p = self[2]
  if a then
    if b then
      if type(a) == "number" then
        r:set(a, b)
        if g then
          p:set(f, g)
        else
          p:set(f)
        end
        self.angle = c
        self.large_arc = d
        self.sweep = e
        return self
      else
        r:set(a)
        if f then
          p:set(e, f)
        else
          p:set(e)
        end
        self.angle = b
        self.large_arc = c
        self.sweep = d
        return self
      end
    else
      r:set(a[1])
      p:set(a[2])
      self.angle = a.angle
      self.large_arc = a.large_arc
      self.sweep = a.sweep
      return self
    end
  else
    r:set()
    p:set()
    self.angle = 0
    self.large_arc = false
    self.sweep = false
    return self
  end
end

-- tostring(self)
function metatable:__tostring()
  local r = self[1]
  local p = self[2]
  return ("A%.17g,%.17g %.17g %d,%d %.17g,%.17g"):format(r[1], r[2], self.angle, self.large_arc and 1 or 0, self.sweep and 1 or 0, p[1], p[2])
end

-- class(number a, number b, number c, boolean d, boolean e, number f, number g)
-- class(number a, number b, number c, boolean d, boolean e, tuple2 f)
-- class(tuple2 a, number b, boolean c, boolean d, number e, number f)
-- class(tuple2 a, number b, boolean c, boolean d, tuple2 e)
-- class(arcto a)
-- class()
return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(class.set({ vector2(), point2() }, ...), metatable)
  end;
})
