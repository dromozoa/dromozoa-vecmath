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

local matrix3 = require "dromozoa.vecmath.matrix3"
local vector3 = require "dromozoa.vecmath.vector3"

local verbose = os.getenv "VERBOSE" == "1"

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

local data = assert(loadfile "test/matrix3d.lua")()

local m = matrix3()
local v = vector3()
local eps = 0.000001

local m1 = matrix3(data[1])
local m2 = matrix3(data[2])
local v1 = vector3(data[3])

if verbose then
  print(tostring(m1))
  print(tostring(m2))
  print(tostring(v1))
end

-- javax.vecmath bug
local d = data.set_scale2
d[1], d[2] = d[2], d[1]
d[4], d[5] = d[5], d[4]
d[7], d[8] = d[8], d[7]
if verbose then
  print(m:set(m1):set_scale(2))
  print(matrix3(d))
end
assert(m:set(m1):set_scale(2):epsilon_equals(d, eps))

assert(math.abs(m1:get_scale() - data.get_scale) < eps)

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

assert(m:invert(m1):epsilon_equals(data.invert, eps))
assert(m:invert(m:set(m1)):epsilon_equals(data.invert, eps))
assert(m:set(m1):invert():epsilon_equals(data.invert, eps))

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

assert(m:mul_normalize(m1, m2):epsilon_equals(data.mul_normalize, eps))
assert(m:mul_transpose_both(m1, m2):equals(data.mul_transpose_both))
assert(m:mul_transpose_right(m1, m2):equals(data.mul_transpose_right))
assert(m:mul_transpose_left(m1, m2):equals(data.mul_transpose_left))

-- javax.vecmath bug
local d = data.normalize
d[1], d[2] = d[2], d[1]
d[4], d[5] = d[5], d[4]
d[7], d[8] = d[8], d[7]
if verbose then
  print(m:normalize(m1))
  print(matrix3(d))
end
assert(m:normalize(m1):epsilon_equals(d, eps))
assert(m:set(m1):normalize():epsilon_equals(d, eps))

if verbose then
  print(m:normalize_cp(m1))
  print(matrix3(data.normalize_cp))
end

assert(m:normalize_cp(m1):epsilon_equals(data.normalize_cp, eps))

assert(m:negate(m1):equals(data.negate))
assert(m:negate(m:set(m1)):equals(data.negate))
assert(m:set(m1):negate():equals(data.negate))

v:set(v1)
m:set(m1):transform(v)
assert(v:equals(data.transform))
v:set()
m:set(m1):transform(v1, v)
assert(v:equals(data.transform))

local m = matrix3(0,0,0,0,0,0,0,0,nil)
assert(not m[9])
assert(not m.m33)
