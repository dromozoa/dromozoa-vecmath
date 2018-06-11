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

local point3 = require "dromozoa.vecmath.point3"

local p1 = point3(3,3,3)
for z = 1, 7 do
  for y = 1, 7 do
    for x = 1, 7 do
      local p2 = point3(x,y,z)
      local d2 = (x - 3)^2 + (y - 3)^2 + (z - 3)^2
      assert(p1:distance_squared(p2) == d2)
      assert(p1:distance(p2) == math.sqrt(d2))
      local d1 = math.abs(x - 3) + math.abs(y - 3) + math.abs(z - 3)
      assert(p1:distance_l1(p2) == d1)
      assert(p2:distance_l1(p1) == d1)
      local dinf = math.max(math.abs(x - 3), math.abs(y - 3), math.abs(z - 3))
      assert(p1:distance_linf(p2) == dinf)
      assert(p2:distance_linf(p1) == dinf)
    end
  end
end

assert(point3():project{1,2,3,4} :equals {1/4,2/4,3/4})
