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
local svd3 = require "dromozoa.vecmath.svd3"

local verbose = os.getenv "VERBOSE" == "1"

local epsilon = 1e-9

local function test_svd(m, expect)
  local a = matrix3(m)
  local u = matrix3():set_identity()
  local v = matrix3():set_identity()
  local sx, sy, sz = svd3(a, u, v)
  assert(sx == a.m11)
  assert(sy == a.m22)
  assert(sz == a.m33)
  local e1 = math.abs(sx - expect[1])
  local e2 = math.abs(sy - expect[2])
  local e3 = math.abs(sz - expect[3])
  if verbose then
    print(("="):rep(80))
    print(tostring(m))
    print(("-"):rep(80))
    print(tostring(a))
    print(tostring(u))
    print(tostring(v))
  end
  assert(e1 < epsilon)
  assert(e2 < epsilon)
  assert(e3 < epsilon)
  local b = matrix3():mul(u, a)
  b:mul_transpose_right(b, v)
  if verbose then
    print(tostring(b))
  end
  assert(m:epsilon_equals(b, epsilon))
end

test_svd(matrix3(16,-1,1,2,12,1,1,3,-24), { 24.2234016039591, 16.1770571732806, 12.0220479098082 })
test_svd(matrix3(1,1/2,1/3,1/2,1/3,1/4,1/3,1/4,1/5), { 1.4083189271237, 0.1223270658539, 0.0026873403558 })
test_svd(matrix3(2,1,4,1,-2,3,-3,-1,1), { 5.4842821997180, 3.5307487547555, 1.8591562561142 })
test_svd(matrix3(1,1,2,1,2,3,1,2,3), { 5.8157204060426, 0.4211842337259, 0 })
test_svd(matrix3(1,2,3,1,2,3,1,2,3), { 6.4807406984079, 0, 0 })
