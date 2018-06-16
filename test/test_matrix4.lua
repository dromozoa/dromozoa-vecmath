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

local axis_angle4 = require "dromozoa.vecmath.axis_angle4"
local matrix3 = require "dromozoa.vecmath.matrix3"
local matrix4 = require "dromozoa.vecmath.matrix4"
local point3 = require "dromozoa.vecmath.point3"
local quat4 = require "dromozoa.vecmath.quat4"
local vector3 = require "dromozoa.vecmath.vector3"
local vector4 = require "dromozoa.vecmath.vector4"

local verbose = os.getenv "VERBOSE" == "1"
local epsilon = 1e-6

local data = assert(loadfile "test/matrix4.lua")()

local m1 = matrix4(data[1])
local m2 = matrix4(data[2])
local p1 = point3(data.p1)
local v1 = vector3(data.v1)
local v2 = vector4(data.v2)
local q1 = quat4(data.q1)
local a1 = axis_angle4(data.a1)
local n1 = matrix3(data.n1)

local m = matrix4()
local n = matrix3()
local p = point3()
local v = vector3()
local q = quat4()
local t = vector4()

m1:get(n)
if verbose then
  print(tostring(m1))
  print(tostring(n))
  print(tostring(matrix3(data.get_matrix3)))
end
assert(n:epsilon_equals(data.get_matrix3, epsilon))

n:set()
m1:get(n, v)
assert(n:epsilon_equals(data.get_matrix3_vector3[1], epsilon))
assert(v:equals(data.get_matrix3_vector3[2]))

m1:get(q)
assert(q:epsilon_equals(data.get_quat4, epsilon))

v:set()
m1:get(v)
assert(v:equals(data.get_vector3))

n:set()
m1:get_rotation_scale(n)
assert(n:equals(data.get_rotation_scale))

assert(math.abs(m1:get_scale() - data.get_scale) <= epsilon)

m:set(m1):set_rotation_scale(n1)
assert(m:equals(data.set_rotation_scale))

m:set(m1):set_scale(2)
if verbose then
  print(tostring(m))
  print(tostring(matrix4(data.set_scale2)))
end
assert(m:epsilon_equals(data.set_scale2, epsilon))

assert(m:add(2, m1):equals(data.add2))
assert(m:set(m1):add(2):equals(data.add2))
assert(m:add(m1, m2):equals(data.add))
assert(m:set(m1):add(m2):equals(data.add))
assert(m:sub(m1, m2):equals(data.sub))
assert(m:set(m1):sub(m2):equals(data.sub))
assert(m:transpose(m1):equals(data.transpose))
assert(m:set(m1):transpose():equals(data.transpose))
assert(m:set(n1):equals(data.set_matrix3))
assert(m:set(q1):epsilon_equals(data.set_quat4, epsilon))

if verbose then
  print(tostring(m:set(a1)))
  print(tostring(matrix4(data.set_axis_angle4)))
end
assert(m:set(a1):equals(data.set_axis_angle4, epsilon))
assert(m:set(q1, v1, 2):epsilon_equals(data.set_quat4_vector3_2, epsilon))
assert(m:set(m1):equals(data.set_matrix4))

assert(m:invert(m1):epsilon_equals(data.invert, epsilon))
assert(m:set(m1):invert():epsilon_equals(data.invert, epsilon))
assert(m:set(m1):determinant() == data.determinant)

if verbose then
  print(tostring(m:set(v1)))
  print(tostring(matrix4(data.set_vector3)))
end
assert(m:set(v1):equals(data.set_vector3))
assert(m:set(2, v1):equals(data.set_2_vector3))
assert(m:set(v1, 2):equals(data.set_vector3_2))
assert(m:set(n1, v1, 2):equals(data.set_matrix3_vector3_2))
assert(m:set(m1):set_translation(v1):equals(data.set_translation))

if verbose then
  print(tostring(m:rot_x(2)))
  print(tostring(matrix4(data.rot_x2)))
end
assert(m:rot_x(2):equals(data.rot_x2))
if verbose then
  print(tostring(m:rot_y(2)))
  print(tostring(matrix4(data.rot_y2)))
end
assert(m:rot_y(2):equals(data.rot_y2))
assert(m:rot_z(2):equals(data.rot_z2))

assert(m:mul(2, m1):equals(data.mul2))
assert(m:set(m1):mul(2):equals(data.mul2))
assert(m:mul(m1, m2):equals(data.mul))
assert(m:set(m1):mul(m2):equals(data.mul))
assert(m:mul_transpose_both(m1, m2):equals(data.mul_transpose_both))
assert(m:mul_transpose_right(m1, m2):equals(data.mul_transpose_right))
assert(m:mul_transpose_left(m1, m2):equals(data.mul_transpose_left))

m:set(m1):transform(t:set(v2))
if verbose then
  print(tostring(t))
  print(tostring(vector4(data.transform_tuple4)))
end
assert(t:equals(data.transform_tuple4))
t:set()
if verbose then
  print(tostring(v2))
  print(tostring(t))
  print(tostring(vector4(data.transform_tuple4)))
end
m:transform(v2, t)
assert(t:equals(data.transform_tuple4))

m:transform(p:set(p1))
if verbose then
  print(tostring(p1))
  print(tostring(p))
  print(tostring(vector3(data.transform_point3)))
end
assert(p:equals(data.transform_point3))

m:set(m1):set_rotation(n1)
if verbose then
  print(tostring(m))
  print(tostring(matrix4(data.set_rotation_matrix3)))
end
assert(m:epsilon_equals(data.set_rotation_matrix3, epsilon))

m:set(m1):set_rotation(q1)
assert(m:epsilon_equals(data.set_rotation_quat4, epsilon))

m:set(m1):set_rotation(a1)
assert(m:epsilon_equals(data.set_rotation_axis_angle4, epsilon))

assert(m:set_zero():equals(data.set_zero))

assert(m:negate(m1):equals(data.negate))
assert(m:set(m1):negate():equals(data.negate))
