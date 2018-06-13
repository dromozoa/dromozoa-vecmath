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
local quat4 = require "dromozoa.vecmath.quat4"

local verbose = os.getenv "VERBOSE" == "1"
local epsilon = 1e-9

local function check1(data)
  local q = quat4(data.quat4)
  local a = axis_angle4(data.axis_angle4)
  local m3 = matrix3(data.matrix3)

  if verbose then
    print(tostring(q))
    print(tostring(a))
    print(tostring(m3))
    print(tostring(axis_angle4(q)))
    print(tostring(axis_angle4(m3)))
  end
  assert(axis_angle4(q):equals(a))
  assert(axis_angle4(m3):epsilon_equals(a, epsilon))
end

local data = assert(loadfile "test/rotation.lua")()
check1(data[1])
