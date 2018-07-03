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

local verbose = os.getenv "VERBOSE" == "1"
local tightness = 0.5
local n = 64
local epsilon = 1e-9

local function catmull_rom(p1, p2, p3, p4, t)
  local p2 = vecmath.point2(p2)
  local v1 = vecmath.vector2():sub(p3, p1):scale(tightness)
  local v2 = vecmath.vector2():sub(p4, p2):scale(tightness)
  local p3 = vecmath.point2(p3)

  local u = 1 - t
  p2:scale((1 + 2 * t) * u * u)
  v1:scale(t * u * u)
  v2:scale(t * t * u)
  p3:scale(t * t * (1 + 2 * u))

  return vecmath.point2():add(p2):add(v1):sub(v2):add(p3)
end

local function to_cubic_bezier(p1, p2, p3, p4)
  local v1 = vecmath.vector2():sub(p3, p1):scale(tightness):scale(1/3)
  local v2 = vecmath.vector2():sub(p4, p2):scale(tightness):scale(1/3)
  local q1 = vecmath.point2():add(p2, v1)
  local q2 = vecmath.point2():sub(p3, v2)
  return q1, q2
end

local function check(p1, p2, p3, p4)
  for i = 0, n do
    local t = i / n
    local p = curve.catmull_rom({ p1, p2, p3, p4 }, t, vecmath.point2())
    local r = catmull_rom(p1, p2, p3, p4, t)
    if verbose then
      print(tostring(p))
    end
    assert(p:equals(r))
  end

  local q = curve.catmull_rom_to_cubic_bezier({ p1, p2, p3, p4 }, { vecmath.point2(), vecmath.point2(), vecmath.point2(), vecmath.point2() })
  local r1, r2 = to_cubic_bezier(p1, p2, p3, p4)
  if verbose then
    print(tostring(q[2]), tostring(q[3]))
    print(tostring(r1), tostring(r2))
  end
  assert(q[2]:epsilon_equals(r1, epsilon))
  assert(q[3]:epsilon_equals(r2, epsilon))
end

check(vecmath.point2(0,0), vecmath.point2(1,1), vecmath.point2(2,-1), vecmath.point2(3,0))
check(vecmath.point2(1,1), vecmath.point2(1,1), vecmath.point2(2,-1), vecmath.point2(3,0))
check(vecmath.point2(0,0), vecmath.point2(1,1), vecmath.point2(2,-1), vecmath.point2(2,-1))
check(vecmath.point2(1,1), vecmath.point2(1,1), vecmath.point2(2,-1), vecmath.point2(2,-1))
check(vecmath.point2(0,0), vecmath.point2(1,0), vecmath.point2(0,1), vecmath.point2(0,0))
check(vecmath.point2(0,0), vecmath.point2(1,0), vecmath.point2(0,1), vecmath.point2(1,0))
check(vecmath.point2(0,0), vecmath.point2(1,0), vecmath.point2(0,1), vecmath.point2(0,1))
