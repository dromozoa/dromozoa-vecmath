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

assert(m:set_scale(2) :equals {2,0,0,0,2,0,0,0,2})

m:set_identity()
for i = 1, 16 do
  m:set_scale(i)
  assert(m:get_scale() == i)
end

local m = matrix3(1,2,3,4,5,6,7,8,9)
assert(m:add(2) :equals {3,4,5,6,7,8,9,10,11})
local m = matrix3(1,2,3,4,5,6,7,8,9)
assert(m:add(m) :equals {2,4,6,8,10,12,14,16,18})
local m = matrix3(1,2,3,4,5,6,7,8,9)
assert(m:add(2, m) :equals {3,4,5,6,7,8,9,10,11})
local m = matrix3(1,2,3,4,5,6,7,8,9)
assert(m:add(m, m) :equals {2,4,6,8,10,12,14,16,18})

local m1 = matrix3(9,9,9,9,9,9,9,9,9)
local m2 = matrix3(1,2,3,4,5,6,7,8,9)
assert(m1:sub(m2) :equals {8,7,6,5,4,3,2,1,0})
local m1 = matrix3(9,9,9,9,9,9,9,9,9)
local m2 = matrix3(1,2,3,4,5,6,7,8,9)
assert(m1:sub(m2,m1) :equals {-8,-7,-6,-5,-4,-3,-2,-1,0})

local m = matrix3(1,2,3,4,5,6,7,8,9)
assert(m:transpose() :equals {1,4,7,2,5,8,3,6,9})
assert(m:transpose(m) :equals {1,2,3,4,5,6,7,8,9})

local m1 = matrix3(1,2,1,2,1,0,1,1,2)
local m2 = matrix3(1,2,1,2,1,0,1,1,2)
assert(m1:determinant() == -5)
assert(m1:invert() :equals {-0.4,0.6,0.2,0.8,-0.2,-0.4,-0.2,-0.2,0.6})
assert(m1:invert(m2) :equals {-0.4,0.6,0.2,0.8,-0.2,-0.4,-0.2,-0.2,0.6})

local m = matrix3():rot_x(math.pi / 4)
if verbose then
  print(tostring(m))
end
local v = vector3(1,1,1)
m:transform(v)
if verbose then
  print(tostring(v))
end
assert(v:epsilon_equals({1,0,math.sqrt(2)}, 0.0001))

local m = matrix3():rot_y(math.pi / 4)
if verbose then
  print(tostring(m))
end
local v = vector3(1,1,1)
m:transform(v)
if verbose then
  print(tostring(v))
end
assert(v:epsilon_equals({math.sqrt(2),1,0}, 0.0001))

local m = matrix3():rot_z(math.pi / 4)
if verbose then
  print(tostring(m))
end
local v = vector3(1,1,1)
m:transform(v)
if verbose then
  print(tostring(v))
end
assert(v:epsilon_equals({0,math.sqrt(2),1}, 0.0001))

local m = matrix3(2)
local v = vector3(1,1,1)
m:transform(v, v)
assert(v :equals {2,2,2})
