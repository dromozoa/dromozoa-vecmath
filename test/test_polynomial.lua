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

local polynomial = require "dromozoa.vecmath.polynomial"

local verbose = os.getenv "VERBOSE" == "1"

-- x^2 - 3*x + 2
local p = polynomial(2, -3, 1)
assert(p:eval(0) == 2)
assert(p:eval(1) == 0)
assert(p:eval(2) == 0)

local d = polynomial():deriv(p)
assert(#d == 2)
assert(d[1] == -3)
assert(d[2] == 2)
assert(d[3] == nil)

local d = polynomial(p):deriv()
assert(#d == 2)
assert(d[1] == -3)
assert(d[2] == 2)
assert(d[3] == nil)

local i = polynomial():integ(p)
assert(#i == 4)
assert(i[1] ==  0)
assert(i[2] ==  2)
assert(i[3] == -3/2)
assert(i[4] ==  1/3)

local i = polynomial(p):integ(42)
assert(#i == 4)
assert(i[1] ==  42)
assert(i[2] ==  2)
assert(i[3] == -3/2)
assert(i[4] ==  1/3)

local p = polynomial(1,1,1,1,1,1,1,1)
p:set{1,-2,1}
assert(#p == 3)

local p1 = polynomial(3,2,1)
local p2 = polynomial(8,7,6,5,4)

local p = polynomial():add(p1, p2)
assert(#p == 5)
assert(p[1] == 11)
assert(p[2] == 9)
assert(p[3] == 7)
assert(p[4] == 5)
assert(p[5] == 4)

local p = polynomial():add(p2, p1)
assert(#p == 5)
assert(p[1] == 11)
assert(p[2] == 9)
assert(p[3] == 7)
assert(p[4] == 5)
assert(p[5] == 4)

local p = polynomial(p1):add(p2)
assert(#p == 5)
assert(p[1] == 11)
assert(p[2] == 9)
assert(p[3] == 7)
assert(p[4] == 5)
assert(p[5] == 4)

local p = polynomial(p2):add(p1)
assert(#p == 5)
assert(p[1] == 11)
assert(p[2] == 9)
assert(p[3] == 7)
assert(p[4] == 5)
assert(p[5] == 4)


local p = polynomial(p1):add(p1)
assert(#p == 3)
assert(p[1] == 6)
assert(p[2] == 4)
assert(p[3] == 2)

local p = polynomial():sub(p1, p2)
assert(#p == 5)
assert(p[1] == -5)
assert(p[2] == -5)
assert(p[3] == -5)
assert(p[4] == -5)
assert(p[5] == -4)

local p = polynomial():sub(p2, p1)
assert(#p == 5)
assert(p[1] == 5)
assert(p[2] == 5)
assert(p[3] == 5)
assert(p[4] == 5)
assert(p[5] == 4)

local p = polynomial(p1):sub(p2)
assert(#p == 5)
assert(p[1] == -5)
assert(p[2] == -5)
assert(p[3] == -5)
assert(p[4] == -5)
assert(p[5] == -4)

local p = polynomial(p2):sub(p1)
assert(#p == 5)
assert(p[1] == 5)
assert(p[2] == 5)
assert(p[3] == 5)
assert(p[4] == 5)
assert(p[5] == 4)

local p = polynomial(p1):sub(p1)
assert(#p == 3)
assert(p[1] == 0)
assert(p[2] == 0)
assert(p[3] == 0)

-- https://docs.scipy.org/doc/numpy/reference/generated/numpy.polyder.html#numpy.polyder
local p = polynomial(1,1,1,1):deriv()
assert(#p == 3)
assert(p[1] == 1)
assert(p[2] == 2)
assert(p[3] == 3)
assert(p:eval(2) == 17)

-- https://docs.scipy.org/doc/numpy/reference/generated/numpy.polyint.html#numpy.polyint
local p = polynomial(1,1,1):integ()
assert(#p == 4)
assert(p[1] == 0)
assert(p[2] == 1)
assert(p[3] == 1/2)
assert(p[4] == 1/3)
p:deriv()
assert(#p == 3)
assert(p[1] == 1)
assert(p[2] == 1)
assert(p[3] == 1)

-- https://docs.scipy.org/doc/numpy/reference/generated/numpy.polyadd.html#numpy.polyadd
local p = polynomial():add({2,1}, {4,5,9})
assert(#p == 3)
assert(p[1] == 6)
assert(p[2] == 6)
assert(p[3] == 9)

-- https://docs.scipy.org/doc/numpy/reference/generated/numpy.polysub.html#numpy.polysub
local p = polynomial():sub({-2,10,2}, {-4,10,3})
assert(#p == 3)
assert(p[1] == 2)
assert(p[2] == 0)
assert(p[3] == -1)

-- https://docs.scipy.org/doc/numpy/reference/generated/numpy.polymul.html#numpy.polymul
local p = polynomial():mul({3,2,1}, {1,5,9})
assert(#p == 5)
assert(p[1] == 3)
assert(p[2] == 17)
assert(p[3] == 38)
assert(p[4] == 23)
assert(p[5] == 9)

local p = polynomial(1,2,3):mul(3)
assert(#p == 3)
assert(p[1] == 3)
assert(p[2] == 6)
assert(p[3] == 9)

local p = polynomial(1,1,1,1):mul(3, {1,2,3})
assert(#p == 3)
assert(p[1] == 3)
assert(p[2] == 6)
assert(p[3] == 9)

-- x^2 - 3*x + 2
local p = polynomial(2, -3, 1)
p:mul(p)
assert(#p == 5)
assert(p[1] == 4)
assert(p[2] == -12)
assert(p[3] == 13)
assert(p[4] == -6)
assert(p[5] == 1)

