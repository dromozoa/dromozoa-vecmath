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

local matrix2 = require "dromozoa.vecmath.matrix2"
local matrix3 = require "dromozoa.vecmath.matrix3"
local point2 = require "dromozoa.vecmath.point2"
local vector2 = require "dromozoa.vecmath.vector2"
local vector3 = require "dromozoa.vecmath.vector3"

local verbose = os.getenv "VERBOSE" == "1"
local epsilon = 1e-6

local m = matrix3()
local s = tostring(m)
if verbose then
  print(s)
end
assert(s == [[
0, 0, 0
0, 0, 0
0, 0, 0
]])

local m = matrix3(1,2,3,4,5,6,7,8,9)
local s = tostring(m)
if verbose then
  print(s)
end
assert(s == [[
1, 2, 3
4, 5, 6
7, 8, 9
]])

assert(m:set_identity() :equals {1,0,0,0,1,0,0,0,1})
local s = tostring(m)
if verbose then
  print(s)
end
assert(s == [[
1, 0, 0
0, 1, 0
0, 0, 1
]])

local data = assert(loadfile "test/matrix3.lua")()

local m = matrix3()
local v = vector3()

local m1 = matrix3(data[1])
local m2 = matrix3(data[2])
local v1 = vector3(data[3])

if verbose then
  print(tostring(m1))
  print(tostring(m2))
  print(tostring(v1))
end

if verbose then
  print(tostring(m:set(m1):set_scale(2)))
  print(tostring(matrix3(data.set_scale2)))
end
assert(m:set(m1):set_scale(2):epsilon_equals(data.set_scale2, epsilon))

assert(math.abs(m1:get_scale() - data.get_scale) <= epsilon)

assert(m:add(2, m1):equals(data.add2))
assert(m:add(2, m:set(m1)):equals(data.add2))
assert(m:set(m1):add(2):equals(data.add2))

assert(m:add(m1, m2):equals(data.add))
assert(m:add(m1, m:set(m2)):equals(data.add))
assert(m:set(m1):add(m2):equals(data.add))

assert(m:sub(m1, m2):equals(data.sub))
assert(m:sub(m1, m:set(m2)):equals(data.sub))
assert(m:set(m1):sub(m2):equals(data.sub))

assert(m:transpose(m1):equals(data.transpose))
assert(m:transpose(m:set(m1)):equals(data.transpose))
assert(m:set(m1):transpose():equals(data.transpose))

assert(m:invert(m1):epsilon_equals(data.invert, epsilon))
assert(m:invert(m:set(m1)):epsilon_equals(data.invert, epsilon))
assert(m:set(m1):invert():epsilon_equals(data.invert, epsilon))

assert(m1:determinant() == data.determinant)

assert(m:set(m1):rot_x(2):equals(data.rot_x2))
assert(m:set(m1):rot_y(2):equals(data.rot_y2))
assert(m:set(m1):rot_z(2):equals(data.rot_z2))

assert(m:mul(2, m1):equals(data.mul2))
assert(m:mul(2, m:set(m1)):equals(data.mul2))
assert(m:set(m1):mul(2):equals(data.mul2))

assert(m:mul(m1, m2):equals(data.mul))
assert(m:mul(m1, m:set(m2)):equals(data.mul))
assert(m:set(m1):mul(m2):equals(data.mul))

if verbose then
  print(tostring(m:mul_normalize(m1, m2)))
  print(tostring(matrix3(data.mul_normalize)))
end
assert(m:mul_normalize(m1, m2):epsilon_equals(data.mul_normalize, epsilon))
assert(m:mul_transpose_both(m1, m2):equals(data.mul_transpose_both))
assert(m:mul_transpose_right(m1, m2):equals(data.mul_transpose_right))
assert(m:mul_transpose_left(m1, m2):equals(data.mul_transpose_left))

if verbose then
  print(tostring(m:normalize(m1)))
  print(tostring(matrix3(data.normalize)))
end
assert(m:normalize(m1):epsilon_equals(data.normalize, epsilon))
assert(m:set(m1):normalize():epsilon_equals(data.normalize, epsilon))

if verbose then
  print(tostring(m:normalize_cp(m1)))
  print(tostring(matrix3(data.normalize_cp)))
end
assert(m:normalize_cp(m1):epsilon_equals(data.normalize_cp, epsilon))

assert(m:negate(m1):equals(data.negate))
assert(m:negate(m:set(m1)):equals(data.negate))
assert(m:set(m1):negate():equals(data.negate))

v:set(v1)
assert(m:set(m1):transform(v) == v)
assert(v:equals(data.transform))
v:set()
assert(m:set(m1):transform(v1, v) == v)
assert(v:equals(data.transform))

local m = matrix3(0,0,0,0,0,0,0,0,nil)
assert(not m[9])
assert(not m.m33)

m:rot_z(math.pi * 0.5)
m.m13 = 10
m.m23 = 20
assert(m:transform(point2(3,4)):epsilon_equals({6,23}, epsilon))
assert(m:transform(vector2(3,4)):epsilon_equals({-4,3}, epsilon))

if verbose then
  print(tostring(matrix3(matrix2():rot(math.pi/4), vector2(10, 20), 2)))
end
assert(matrix3(matrix2():rot(math.pi/4), vector2(10, 20), 2):equals{
  2*math.cos(math.pi/4), -2*math.sin(math.pi/4), 10;
  2*math.sin(math.pi/4),  2*math.cos(math.pi/4), 20;
  0, 0, 1;
})
assert(matrix3(2,{1,3}):equals{2,0,1;0,2,3;0,0,1})
assert(matrix3({1,3},2):equals{2,0,2;0,2,6;0,0,1})
assert(matrix3(matrix2{1,2,3,4}):equals{1,2,0;3,4,0;0,0,1})
assert(matrix3{1,3}:equals{1,0,1;0,1,3;0,0,1})

local m = matrix3(1,2,3,4,5,6,0,0,1)
assert(m:set_rotation_scale{2,1,5,4}:equals{2,1,3,5,4,6,0,0,1})
assert(m:set_translation{6,3}:equals{2,1,6,5,4,3,0,0,1})
assert(m:set_rotation{0,-1,1,0}:epsilon_equals({0,-0.443273615295610,6,6.767828935632369,0,3,0,0,1}, epsilon))

local m = matrix3(1,2,3,4,5,6,0,0,1)
local n = matrix2()
local v = vector2()
local result = { m:get(n, v) }
assert(math.abs(result[1] - 6.767828935632369) <= epsilon)
assert(result[2] == n)
assert(result[3] == v)
if verbose then
  print(tostring(n))
end
assert(n:epsilon_equals({-0.554700196225229,0.832050294337844,0.832050294337844,0.554700196225229}, epsilon))
assert(v:equals{3,6})
if verbose then
  print(tostring(m:get(matrix2())))
end
assert(m:get(matrix2()):epsilon_equals({-0.554700196225229,0.832050294337844,0.832050294337844,0.554700196225229}, epsilon))
assert(m:get(vector2()):equals{3,6})
assert(m:get_rotation_scale(matrix2()):equals{1,2,4,5})
