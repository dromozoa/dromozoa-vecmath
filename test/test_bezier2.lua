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
local bezier = require "dromozoa.vecmath.bezier"

local verbose = os.getenv "VERBOSE" == "1"
local tightness = 0.5
local epsilon = 1e-9
local n = 16

local point2 = vecmath.point2
local point3 = vecmath.point3

local function quadratic_bezier(p1, p2, p3, t)
  local u = 1 - t
  local a = u * u
  local b = 2 * u * t
  local c = t * t
  local q = point2()
  q:scale_add(a, p1, q)
  q:scale_add(b, p2, q)
  q:scale_add(c, p3, q)
  return q
end

local function rational_quadratic_bezier(p1, p2, p3, t)
  local u = 1 - t
  local a = u * u     * p1.z
  local b = 2 * u * t * p2.z
  local c = t * t     * p3.z
  local d = a + b + c
  local q = point2()
  q:scale_add(a / d, p1, q)
  q:scale_add(b / d, p2, q)
  q:scale_add(c / d, p3, q)
  return q
end

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

local function check_catmull_rom(p1, p2, p3, p4, t)
  local b = bezier():set_catmull_rom(p1, p2, p3, p4)
  for i = 0, n do
    local t = i / n
    local r = catmull_rom(p1, p2, p3, p4, t)
    local p = b:eval(t, point2())
    if verbose then
      print(tostring(p), tostring(r))
    end
    assert(p:epsilon_equals(r, epsilon))
  end
end

local p1 = point2(0, 0)
local p2 = point2(1, 1)
local p3 = point2(2, 0)

local b = bezier(p1, p2, p3)
assert(b:get(1, point2()):equals(p1))
assert(b:get(2, point2()):equals(p2))
assert(b:get(3, point2()):equals(p3))
assert(b:get(1, point3()):equals{ p1.x, p1.y, 1 })
assert(b:get(2, point3()):equals{ p2.x, p2.y, 1 })
assert(b:get(3, point3()):equals{ p3.x, p3.y, 1 })

for i = 0, n do
  local t = i / n
  local r = quadratic_bezier(p1, p2, p3, t)
  local p = b:eval(t, point2())
  local q = point2():project(b:eval(t, point3()))
  if verbose then
    print(tostring(r), tostring(p), tostring(q))
  end
  assert(p:epsilon_equals(r, epsilon))
  assert(q:epsilon_equals(r, epsilon))
end

local z = math.cos(math.pi / 4)
local p1 = point3(-200,     -200,     1)
local p2 = point3( 200 * z, -200 * z, z)
local p3 = point3( 200,      200,     1)
local q1 = point3(-200, -200, 1)
local q2 = point3( 200, -200, z)
local q3 = point3( 200,  200, 1)

local b = bezier(p1, p2, p3)
assert(b:get(1, point2()):equals{ -200, -200 })
assert(b:get(2, point2()):equals{  200, -200 })
assert(b:get(3, point2()):equals{  200,  200 })
assert(b:get(1, point3()):equals(p1))
assert(b:get(2, point3()):equals(p2))
assert(b:get(3, point3()):equals(p3))

for i = 0, n do
  local t = i / n
  local r = rational_quadratic_bezier(q1, q2, q3, t)
  local p = b:eval(t, point2())
  local q = point2():project(b:eval(t, point3()))
  if verbose then
    print(tostring(r), tostring(p), tostring(q))
  end
  assert(p:epsilon_equals(r, epsilon))
  assert(q:epsilon_equals(r, epsilon))
end

local b = bezier(p1, p2, p3)
local p, b1, b2 = b:eval(1/4, point2(), bezier(), bezier())
local d = p:distance(point2(-200, 200))
if verbose then
  print "--"
  print(tostring(p))
  print "--"
  print(tostring(b1:get(1, point3())))
  print(tostring(b1:get(2, point3())))
  print(tostring(b1:get(3, point3())))
  print "--"
  print(tostring(b2:get(1, point3())))
  print(tostring(b2:get(2, point3())))
  print(tostring(b2:get(3, point3())))
end
assert(d == 400)

local b = bezier(p1, p2, p3)
local p, b1, b2 = b:eval(1/4, point3(), bezier(), bezier())
assert(b1)
assert(b2)
if verbose then
  print "--"
  print(tostring(p))
  print "--"
  print(tostring(b1:get(1, point3())))
  print(tostring(b1:get(2, point3())))
  print(tostring(b1:get(3, point3())))
  print "--"
  print(tostring(b2:get(1, point3())))
  print(tostring(b2:get(2, point3())))
  print(tostring(b2:get(3, point3())))
end

local r = rational_quadratic_bezier(q1, q2, q3, 3/16)
local p = b1:eval(3/4, point2())
local d = p:distance(point2(-200, 200))
if verbose then
  print "--"
  print(tostring(p), tostring(r))
end
assert(d == 400)
assert(p:epsilon_equals(r, epsilon))

local r = rational_quadratic_bezier(q1, q2, q3, 7/16)
local p = b2:eval(1/4, point2())
local d = p:distance(point2(-200, 200))
if verbose then
  print "--"
  print(tostring(p), tostring(r))
end
assert(d == 400)
assert(p:epsilon_equals(r, epsilon))

check_catmull_rom(vecmath.point2(0,0), vecmath.point2(1,1), vecmath.point2(2,-1), vecmath.point2(3,0))
check_catmull_rom(vecmath.point2(1,1), vecmath.point2(1,1), vecmath.point2(2,-1), vecmath.point2(3,0))
check_catmull_rom(vecmath.point2(0,0), vecmath.point2(1,1), vecmath.point2(2,-1), vecmath.point2(2,-1))
check_catmull_rom(vecmath.point2(1,1), vecmath.point2(1,1), vecmath.point2(2,-1), vecmath.point2(2,-1))
check_catmull_rom(vecmath.point2(0,0), vecmath.point2(1,0), vecmath.point2(0,1), vecmath.point2(0,0))
check_catmull_rom(vecmath.point2(0,0), vecmath.point2(1,0), vecmath.point2(0,1), vecmath.point2(1,0))
check_catmull_rom(vecmath.point2(0,0), vecmath.point2(1,0), vecmath.point2(0,1), vecmath.point2(0,1))
