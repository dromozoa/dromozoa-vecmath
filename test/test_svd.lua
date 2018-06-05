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
local svd3 = require "dromozoa.vecmath.svd3"
local vector3 = require "dromozoa.vecmath.vector3"

local a = matrix3(16,-1,1,2,12,1,1,3,-24)
-- local a = matrix3(1, 1/2, 1/3, 1/2, 1/3, 1/4, 1/3, 1/4, 1/5)
-- local a = matrix3(2,1,4,1,-2,3,-3,-1,1)
local b = vector3()

svd3(a, b)

print(tostring(a))
print(tostring(b))
-- for i = 1, 16, 4 do
--   print(b[i], b[i + 1], b[i + 2], b[i + 3])
-- end

local x = matrix3():set(a)
local y = matrix3():transpose(x)
x:mul(y)
print(tostring(x))
eig3(x, 1e-8)
print(tostring(x))

print(vector3(math.sqrt(x.m11), math.sqrt(x.m22), math.sqrt(x.m33)))

