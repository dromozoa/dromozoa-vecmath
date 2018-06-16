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
local axis_angle4 = vecmath.axis_angle4
local matrix3 = vecmath.matrix3
local matrix4 = vecmath.matrix4
local quat4 = vecmath.quat4

local verbose = os.getenv "VERBOSE" == "1"
local epsilon = 1e-9

local function check1(data)
  local q = quat4(data.quat4)
  local a = axis_angle4(data.axis_angle4)
  local m3 = matrix3(data.matrix3)
  local m4 = matrix4(data.matrix4)

  if verbose then
    print "=="
    print("q", tostring(q))
    print("a", tostring(a))
    print("m3", tostring(m3))
    print("m4", tostring(m4))
    print "--"
    print(tostring(axis_angle4(q)))
    print(tostring(axis_angle4(m3)))
    print(tostring(axis_angle4(m4)))
  end
  assert(axis_angle4(q):equals(a))
  assert(axis_angle4(m3):epsilon_equals(a, epsilon))
  assert(axis_angle4(m4):epsilon_equals(a, epsilon))

  local q = quat4(data.quat4)
  local a = axis_angle4(data.axis_angle4)
  q:normalize()
  a.x = a.x * 2
  a.y = a.y * 2
  a.z = a.z * 2
  if verbose then
    print "=="
    print("q", tostring(q))
    print("a", tostring(a))
    print("m3", tostring(m3))
    print("m4", tostring(m4))
    print "--"
    print(tostring(quat4(a)))
    print(tostring(quat4(m3)))
    print(tostring(quat4(m4)))
  end
  assert(quat4(a):epsilon_equals(q, epsilon))
  assert(quat4(m3):equals(q))
  assert(quat4(m4):equals(q))

  local q = quat4(data.quat4)
  local a = axis_angle4(data.axis_angle4)
  a.x = a.x * 2
  a.y = a.y * 2
  a.z = a.z * 2
  if verbose then
    print "=="
    print("q", tostring(q))
    print("a", tostring(a))
    print("m3", tostring(m3))
    print "--"
    print(tostring(matrix3(a)))
    print(tostring(matrix3(q)))
  end
  assert(matrix3(a):epsilon_equals(m3, epsilon))
  assert(matrix3(q):epsilon_equals(m3, epsilon))
end

local function check2(data)
  local n = #data
  local q1 = quat4(data.q1)
  local q2 = quat4(data.q2)
  for i = 1, n do
    local alpha = (i - 1) / (n - 1)
    local q = quat4():interpolate(q1, q2, alpha)
    if verbose then
      print(tostring(q))
    end
    assert(q:epsilon_equals(data[i], epsilon))
    assert(quat4(q1):interpolate(q2, alpha):epsilon_equals(data[i], epsilon))
  end
end

local function check3(data)
  for i = 1, #data.m do
    local m = matrix3(data.m[i])
    local q = quat4(data.q[i])
    if verbose then
      print(tostring(q))
      print(tostring(quat4(m)))
    end
    assert(quat4(m):epsilon_equals(data.q[i], epsilon))
  end
end

local data = assert(loadfile "test/rotation.lua")()
check1(data[1])
check2(data[2])
check3(data[3])
