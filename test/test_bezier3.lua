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

local point2 = vecmath.point2
local point3 = vecmath.point3

local verbose = os.getenv "VERBOSE" == "1"
local epsilon = 1e-9

local t1 = 1/8
local t2 = 3/4

local function check(b1, b2)
  local p = b2:get(1, point2())
  local q = b2:get(b2:size(), point2())

  if verbose then
    print(tostring(p))
    print(tostring(b1:eval(t1, point2())))
    print(tostring(q))
    print(tostring(b1:eval(t2, point2())))
  end

  assert(p:epsilon_equals(b1:eval(t1, point2()), epsilon))
  assert(q:epsilon_equals(b1:eval(t2, point2()), epsilon))

  if b1:is_rational() then
    assert(p:distance{-200,200} - 400 < epsilon)
    assert(q:distance{-200,200} - 400 < epsilon)
  end
end

local p1 = point2(0, 0)
local p2 = point2(1, 1)
local p3 = point2(2, 0)
local p4 = point2(2, 1)

local b1 = bezier(p1, p2, p3, p4)
check(b1, bezier():clip(t1, t2, b1))
check(b1, bezier(b1):clip(t1, t2))

local z = math.cos(math.pi / 4)
local p1 = point3(-200,     -200,     1)
local p2 = point3( 200 * z, -200 * z, z)
local p3 = point3( 200,      200,     1)

local b1 = bezier(p1, p2, p3)
check(b1, bezier():clip(t1, t2, b1))
check(b1, bezier(b1):clip(t1, t2))
