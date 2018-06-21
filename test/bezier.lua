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

local vecmath = require "dromozoa.vecmath"
local curve = require "dromozoa.vecmath.curve"

local n = tonumber(arg[1])
local p1 = vecmath.point2(tonumber(arg[2]), tonumber(arg[3]))
local p2 = vecmath.point2(tonumber(arg[4]), tonumber(arg[5]))
local p3 = vecmath.point2(tonumber(arg[6]), tonumber(arg[7]))
local p4 = vecmath.point2(tonumber(arg[8]), tonumber(arg[9]))

function bezier(p1, p2, p3, p4, t)
  local p1 = vecmath.point2(p1)
  local p2 = vecmath.point2(p2)
  local p3 = vecmath.point2(p3)
  p1:interpolate(p1, p2, t)
  p2:interpolate(p2, p3, t)
  p3:interpolate(p3, p4, t)
  p1:interpolate(p1, p2, t)
  p2:interpolate(p2, p3, t)
  p1:interpolate(p1, p2, t)
  return p1
end

local distance = 0
local max_x = p1.x
local max_y = p1.y
local min_x = p1.x
local min_y = p1.y
io.write(([[
<path d="
  M %.17g %.17g
  L
]]):format(p1.x, p1.y))

local q = p1
for i = 1, n do
  local p = bezier(p1, p2, p3, p4, i / n)
  if max_x < p.x then
    max_x = p.x
  end
  if max_y < p.y then
    max_y = p.y
  end
  if min_x > p.x then
    min_x = p.x
  end
  if min_y > p.y then
    min_y = p.y
  end

  local p2 = curve.cubic_bezier(p1, p2, p3, p4, i / n, vecmath.point2())
  assert(p:epsilon_equals(p2, 1e-9))

  distance = distance + p:distance(q)
  q = p
  io.write(("  %.17g %.17g\n"):format(p.x, p.y))
end
io.write(([[
" fill="none" stroke="black"/>
<!--
  n: %.17g
  distance: %.17g
  min_x: %.17g
  max_x: %.17g
  min_y: %.17g
  max_y: %.17g
-->
]]):format(n, distance, min_x, max_x, min_y, max_y))

