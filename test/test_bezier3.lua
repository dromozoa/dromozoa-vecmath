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

local z = math.cos(math.pi / 4)
local p1 = point3(-200,     -200,     1)
local p2 = point3( 200 * z, -200 * z, z)
local p3 = point3( 200,      200,     1)

local t1 = 1/8
local t2 = 3/4

local b1 = bezier(p1, p2, p3)

local function check(b2)
  local q1 = b2:get(1, point2())
  local q3 = b2:get(3, point2())

  if verbose then
    print(tostring(q1))
    print(tostring(b1:eval(t1, point2())))
    print(tostring(q3))
    print(tostring(b1:eval(t2, point2())))
  end

  assert(q1:epsilon_equals(b1:eval(t1, point2()), epsilon))
  assert(q3:epsilon_equals(b1:eval(t2, point2()), epsilon))

  assert(q1:distance{-200,200} - 400 < epsilon)
  assert(q3:distance{-200,200} - 400 < epsilon)
end

check(bezier():clip(t1, t2, b1))
check(bezier(b1):clip(t1, t2))
