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

local poly1 = require "dromozoa.vecmath.poly1"

local verbose = os.getenv "VERBOSE" == "1"

-- x^2 - 3x + 2
local p = poly1(1, -3, 2)
assert(p:eval(0) == 2)
assert(p:eval(1) == 0)
assert(p:eval(2) == 0)

local d = poly1():deriv(p)
assert(#d == 2)
assert(d[1] == 2)
assert(d[2] == -3)
assert(d[3] == nil)

local d = poly1(p):deriv()
assert(#d == 2)
assert(d[1] == 2)
assert(d[2] == -3)
assert(d[3] == nil)

local i = poly1():integ(p)
assert(#i == 4)
assert(i[1] ==  1/3)
assert(i[2] == -3/2)
assert(i[3] ==  2)
assert(i[4] ==  0)

local i = poly1(p):integ(42)
assert(#i == 4)
assert(i[1] ==  1/3)
assert(i[2] == -3/2)
assert(i[3] ==  2)
assert(i[4] ==  42)

local p = poly1(1,1,1,1,1,1,1,1)
p:set{1,-2,1}
assert(#p == 3)

local p1 = poly1(1,2,3)
local p2 = poly1(4,5,6,7,8)

local p = poly1():add(p1, p2)
assert(#p == 5)
assert(p[1] == 4)
assert(p[2] == 5)
assert(p[3] == 7)
assert(p[4] == 9)
assert(p[5] == 11)

local p = poly1():add(p2, p1)
assert(#p == 5)
assert(p[1] == 4)
assert(p[2] == 5)
assert(p[3] == 7)
assert(p[4] == 9)
assert(p[5] == 11)

local p = poly1(p1):add(p2)
assert(#p == 5)
assert(p[1] == 4)
assert(p[2] == 5)
assert(p[3] == 7)
assert(p[4] == 9)
assert(p[5] == 11)

local p = poly1(p2):add(p1)
assert(#p == 5)
assert(p[1] == 4)
assert(p[2] == 5)
assert(p[3] == 7)
assert(p[4] == 9)
assert(p[5] == 11)

local p = poly1(p1):add(p1)
assert(#p == 3)
assert(p[1] == 2)
assert(p[2] == 4)
assert(p[3] == 6)

local p = poly1():sub(p1, p2)
assert(#p == 5)
assert(p[1] == -4)
assert(p[2] == -5)
assert(p[3] == -5)
assert(p[4] == -5)
assert(p[5] == -5)

local p = poly1():sub(p2, p1)
assert(#p == 5)
assert(p[1] == 4)
assert(p[2] == 5)
assert(p[3] == 5)
assert(p[4] == 5)
assert(p[5] == 5)

local p = poly1(p1):sub(p2)
assert(#p == 5)
assert(p[1] == -4)
assert(p[2] == -5)
assert(p[3] == -5)
assert(p[4] == -5)
assert(p[5] == -5)

local p = poly1(p2):sub(p1)
assert(#p == 5)
assert(p[1] == 4)
assert(p[2] == 5)
assert(p[3] == 5)
assert(p[4] == 5)
assert(p[5] == 5)

local p = poly1(p1):sub(p1)
assert(#p == 3)
assert(p[1] == 0)
assert(p[2] == 0)
assert(p[3] == 0)

-- https://docs.scipy.org/doc/numpy/reference/generated/numpy.polyder.html#numpy.polyder
local p = poly1(1,1,1,1):deriv()
assert(#p == 3)
assert(p[1] == 3)
assert(p[2] == 2)
assert(p[3] == 1)
assert(p:eval(2) == 17)

-- https://docs.scipy.org/doc/numpy/reference/generated/numpy.polyint.html#numpy.polyint
local p = poly1(1,1,1):integ()
assert(#p == 4)
assert(p[1] == 1/3)
assert(p[2] == 1/2)
assert(p[3] == 1)
assert(p[4] == 0)
p:deriv()
assert(#p == 3)
assert(p[1] == 1)
assert(p[2] == 1)
assert(p[3] == 1)

-- https://docs.scipy.org/doc/numpy/reference/generated/numpy.polyadd.html#numpy.polyadd
local p = poly1():add({1,2}, {9,5,4})
assert(#p == 3)
assert(p[1] == 9)
assert(p[2] == 6)
assert(p[3] == 6)

-- https://docs.scipy.org/doc/numpy/reference/generated/numpy.polysub.html#numpy.polysub
local p = poly1():sub({2,10,-2}, {3,10,-4})
assert(#p == 3)
assert(p[1] == -1)
assert(p[2] == 0)
assert(p[3] == 2)
