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
local eig3 = require "dromozoa.vecmath.eig3"
local vector3 = require "dromozoa.vecmath.vector3"

local verbose = os.getenv "VERBOSE" == "1"

local epsilon = 1e-3

local function test_svd(m, expect)
  local a = matrix3(m):mul(matrix3(m):transpose()) -- mul_transpose_right
  local b = matrix3():set_identity()
  eig3(a, b)
  local result = {
    math.sqrt(a.m11);
    math.sqrt(a.m22);
    math.sqrt(a.m33);
  }
  if a.m11 < 0 then result[1] = 0 end
  if a.m22 < 0 then result[2] = 0 end
  if a.m33 < 0 then result[3] = 0 end
  table.sort(result, function (a, b) return b < a end)
  local e1 = math.abs(result[1] - expect[1])
  local e2 = math.abs(result[2] - expect[2])
  local e3 = math.abs(result[3] - expect[3])
  local c = matrix3(b):mul(matrix3(b):transpose())

  if verbose then
    print(("="):rep(80))
    print(tostring(m))
    print(tostring(a))
    print(tostring(b))
    print(tostring(c))
    print(result[1], expect[1], e1)
    print(result[2], expect[2], e2)
    print(result[3], expect[3], e3)
  end
  assert(e1 < epsilon)
  assert(e2 < epsilon)
  assert(e3 < epsilon)
  assert(c:epsilon_equals(matrix3():set_identity(), epsilon))
end

test_svd(matrix3(16,-1,1,2,12,1,1,3,-24), {24.22340, 16.17706, 12.02205})
test_svd(matrix3(1,1/2,1/3,1/2,1/3,1/4,1/3,1/4,1/5), { 1.40832, 0.12233, 0.00269})
test_svd(matrix3(2,1,4,1,-2,3,-3,-1,1), {5.48428, 3.53075, 1.85916})
test_svd(matrix3(1,1,2,1,2,3,1,2,3), {5.81572, 0.42118, 0})
test_svd(matrix3(1,2,3,1,2,3,1,2,3), {6.48074, 0, 0})
