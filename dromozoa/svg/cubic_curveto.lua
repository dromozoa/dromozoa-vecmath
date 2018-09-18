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

local setmetatable = setmetatable

local class = { is_curveto = true }
local metatable = { __index = class }

function metatable:__tostring()
  local p1 = self[1]
  local p2 = self[2]
  local p3 = self[3]
  return ("C%.17g,%.17g %.17g,%.17g %.17g,%.17g"):format(p1[1], p1[2], p2[1], p2[2], p3[1], p3[2])
end

-- class(number a, number b, number c, number d, numer e, number f)
-- class(tuple2 a, tuple2 b, tuple2 c)
-- class()
return setmetatable(class, {
  __call = function (_, a, b, c, d, e, f)
    if d then
      return setmetatable({ point2(a, b), point2(c, d), point2(e, f) }, metatable)
    else
      return setmetatable({ point2(a), point2(b), point2(c) }, metatable)
    end
  end;
})
