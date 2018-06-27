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
local svd2 = require "dromozoa.vecmath.svd2"

local verbose = os.getenv "VERBOSE" == "1"

local epsilon = 1e-9

local function test_svd(m, expect)
  local a = matrix2(m)
  local u = matrix2():set_identity()
  local v = matrix2():set_identity()
  local sx, sy = svd2(a, u, v)
  if verbose then
    print(sx, sy)
  end
  assert(sx == a.m11)
  assert(sy == a.m22)
  local e1 = math.abs(sx - expect[1])
  local e2 = math.abs(sy - expect[2])
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
  local b = matrix2():mul(u, a)
  b:mul_transpose_right(b, v)
  if verbose then
    print(tostring(b))
  end
  assert(m:epsilon_equals(b, epsilon))
end

test_svd(matrix2(1,2,3,4), {5.464985704219043, 0.365966190626257})
test_svd(matrix2(1,1/2,1/2,1/3), {1.2675918792439982, 0.0657414540893351})
test_svd(matrix2(1,2,2,4), {5, 0})
test_svd(matrix2(1,1,1,1), {2, 0})
test_svd(matrix2(9,0,0,3), {9, 3})
test_svd(matrix2(3,0,0,9), {9, 3})
