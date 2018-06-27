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
local vector2 = require "dromozoa.vecmath.vector2"

local verbose = os.getenv "VERBOSE" == "1"
local epsilon = 1e-6

local m = matrix2()
local s = tostring(m)
if verbose then
  print(s)
end
assert(s == [[
0, 0
0, 0
]])

local m = matrix2(1,2,3,4)
local s = tostring(m)
if verbose then
  print(s)
end
assert(s == [[
1, 2
3, 4
]])

local m = matrix2(2)
local s = tostring(m)
if verbose then
  print(s)
end
assert(s == [[
2, 0
0, 2
]])

local m = matrix2{1,2,3,4}
assert(m.m11 == 1)
assert(m.m12 == 2)
assert(m.m21 == 3)
assert(m.m22 == 4)

assert(m:set_identity() :equals {1,0,0,1})
local s = tostring(m)
if verbose then
  print(s)
end
assert(s == [[
1, 0
0, 1
]])

assert(matrix2():add({1,2,3,4}, {5,6,7,8}):equals{6,8,10,12})
assert(matrix2(1,2,3,4):add({5,6,7,8}):equals{6,8,10,12})
assert(matrix2():add(2, {1,2,3,4}):equals{3,4,5,6})
assert(matrix2(1,2,3,4):add(2):equals{3,4,5,6})

assert(matrix2():sub({5,6,7,8}, {1,2,3,4}):equals{4,4,4,4})
assert(matrix2(5,6,7,8):sub{1,2,3,4}:equals{4,4,4,4})

assert(matrix2():transpose{1,2,3,4}:equals{1,3,2,4})
assert(matrix2(1,2,3,4):transpose():equals{1,3,2,4})

assert(matrix2():invert{1,2,3,4}:equals{-2,1,3/2,-1/2})
assert(matrix2(1,2,3,4):invert():equals{-2,1,3/2,-1/2})

assert(matrix2(1,2,3,4):determinant() == -2)

if verbose then
  print(tostring(matrix2():rot(math.pi/2)))
end
assert(matrix2():rot(math.pi/2):epsilon_equals({0,-1,1,0}, epsilon))

assert(matrix2():mul({1,2,3,4}, {5,6,7,8}):equals{19,22,43,50})
assert(matrix2(1,2,3,4):mul({5,6,7,8}):equals{19,22,43,50})
assert(matrix2():mul(2, {1,2,3,4}):equals{2,4,6,8})
assert(matrix2(1,2,3,4):mul(2):equals{2,4,6,8})

assert(matrix2():mul_transpose_both({1,2,3,4}, {5,6,7,8}):equals{23,31,34,46})
assert(matrix2():mul_transpose_right({1,2,3,4}, {5,6,7,8}):equals{17,23,39,53})
assert(matrix2():mul_transpose_left({1,2,3,4}, {5,6,7,8}):equals{26,30,38,44})

assert(matrix2(1):set_zero():equals(matrix2()))
assert(matrix2():negate{1,2,3,4}:equals{-1,-2,-3,-4})
assert(matrix2(1,2,3,4):negate():equals{-1,-2,-3,-4})

local v = vector2(2,3)
assert(matrix2(1,2,3,4):transform(v, vector2()):equals{8,18})
assert(v:equals{2,3})
assert(matrix2(1,2,3,4):transform(v):equals{8,18})
assert(v:equals{8,18})

assert(matrix2():normalize{1,2,3,4}:epsilon_equals({-0.514495755427526,0.857492925712544,0.857492925712544,0.514495755427526}, epsilon))
assert(matrix2(1,2,3,4):normalize():epsilon_equals({-0.514495755427526,0.857492925712544,0.857492925712544,0.514495755427526}, epsilon))
assert(matrix2(1,1/2,1/2,1/3):normalize():epsilon_equals({1,0,0,1}, epsilon))
assert(matrix2(1,2,2,4):normalize():epsilon_equals({1,0,0,1}, epsilon))
assert(matrix2(9,0,0,3):normalize():epsilon_equals({1,0,0,1}, epsilon))
assert(matrix2(3,0,0,9):normalize():epsilon_equals({1,0,0,1}, epsilon))

if verbose then
  print(tostring(matrix2(1,2,3,4):set_scale(2)))
end
assert(matrix2(1,2,3,4):set_scale(2):epsilon_equals({-1.02899151085505,1.71498585142509,1.71498585142509,1.02899151085505}, epsilon))
assert(matrix2(1,2,3,4):get_scale() == 5.464985704219043)

assert(math.abs(matrix2():rot(math.pi/4):get_rotation() - math.pi/4) <= epsilon)
