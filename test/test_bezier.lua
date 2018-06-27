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
local n = 64

local function quadratic_bezier(p1, p2, p3, t)
  local p4 = vecmath:point2():interpolate(p1, p2, t)
  local p5 = vecmath:point2():interpolate(p2, p3, t)
  return vecmath:point2():interpolate(p4, p5, t)
end

local function check_quadratic_bezier(p1, p2, p3)
  for i = 0, n do
    local t = i / n
    local p = curve.quadratic_bezier(p1, p2, p3, t, vecmath.point2())
    local r = quadratic_bezier(p1, p2, p3, t)
    if verbose then
      print(tostring(p))
      print(tostring(r))
    end
    assert(p:equals(r))
  end
end

local function cubic_bezier(p1, p2, p3, p4, t)
  local p5 = vecmath:point2():interpolate(p1, p2, t)
  local p6 = vecmath:point2():interpolate(p2, p3, t)
  local p7 = vecmath:point2():interpolate(p3, p4, t)
  local p8 = vecmath:point2():interpolate(p5, p6, t)
  local p9 = vecmath:point2():interpolate(p6, p7, t)
  return vecmath:point2():interpolate(p8, p9, t)
end

local function check_cubic_bezier(p1, p2, p3, p4)
  for i = 0, n do
    local t = i / n
    local p = curve.cubic_bezier(p1, p2, p3, p4, t, vecmath.point2())
    local r = cubic_bezier(p1, p2, p3, p4, t)
    if verbose then
      print(tostring(p))
    end
    assert(p:equals(r))
  end
end

check_quadratic_bezier(vecmath.point2(0,0), vecmath.point2(1,1), vecmath.point2(2,0))
check_quadratic_bezier(vecmath.point2(1,1), vecmath.point2(1,1), vecmath.point2(2,0))
check_quadratic_bezier(vecmath.point2(0,0), vecmath.point2(1,1), vecmath.point2(1,1))
check_quadratic_bezier(vecmath.point2(1,1), vecmath.point2(1,1), vecmath.point2(1,1))
check_quadratic_bezier(vecmath.point2(0,0), vecmath.point2(1,0), vecmath.point2(0,0))
check_quadratic_bezier(vecmath.point2(0,0), vecmath.point2(1,0), vecmath.point2(0,1))
check_quadratic_bezier(vecmath.point2(0,0), vecmath.point2(1,0), vecmath.point2(1,1))

check_cubic_bezier(vecmath.point2(0,0), vecmath.point2(1,1), vecmath.point2(2,-1), vecmath.point2(3,0))
check_cubic_bezier(vecmath.point2(1,1), vecmath.point2(1,1), vecmath.point2(2,-1), vecmath.point2(3,0))
check_cubic_bezier(vecmath.point2(0,0), vecmath.point2(1,1), vecmath.point2(2,-1), vecmath.point2(2,-1))
check_cubic_bezier(vecmath.point2(1,1), vecmath.point2(1,1), vecmath.point2(2,-1), vecmath.point2(2,-1))
check_cubic_bezier(vecmath.point2(0,0), vecmath.point2(1,0), vecmath.point2(0,1), vecmath.point2(0,0))
check_cubic_bezier(vecmath.point2(0,0), vecmath.point2(1,0), vecmath.point2(0,1), vecmath.point2(1,0))
check_cubic_bezier(vecmath.point2(0,0), vecmath.point2(1,0), vecmath.point2(0,1), vecmath.point2(0,1))
