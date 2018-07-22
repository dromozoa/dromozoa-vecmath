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

local bernstein = require "dromozoa.vecmath.bernstein"
local polynomial = require "dromozoa.vecmath.polynomial"

local verbose = os.getenv "VERBOSE" == "1"

-- 17*binomial(1,0)*(1-t) + 19*binomial(1,1)*t
local b = bernstein(17,19)
assert(b:eval(0)    == 17)
assert(b:eval(0.5)  == 18)
assert(b:eval(0.75) == 18.5)
assert(b:eval(1)    == 19)
assert(b:eval(2)    == 21)

-- 2*binomial(2,0)*(1-t)^2 + 3*binomial(2,1)*(1-t)*t + 5*binomial(2,2)*t^2
local b = bernstein(2,3,5)
assert(b:eval(0)    == 2)
assert(b:eval(0.5)  == 3.25)
assert(b:eval(0.75) == 4.0625)
assert(b:eval(1)    == 5)
assert(b:eval(2)    == 10)

-- 7*binomial(3,0)*(1-t)^3 + 11*binomial(3,1)*(1-t)^2*t + 13*binomial(3,2)*(1-t)*t^2 + 19*binomial(3,3)*t^3
local b = bernstein(7,11,13,19)
assert(b:eval(0)    == 7)
assert(b:eval(0.5)  == 12.25)
assert(b:eval(0.75) == 15.15625)
assert(b:eval(1)    == 19)
assert(b:eval(2)    == 55)

local b = bernstein(1,3,4,6,8)
local p = b:get(polynomial(1,1,1,1,1,1,1,1))
assert(#p == 5)
assert(p[1] ==  1)
assert(p[2] ==  8)
assert(p[3] == -6)
assert(p[4] ==  8)
assert(p[5] == -3)

local b = bernstein(polynomial(1,24,-39,20))
assert(#b == 4)
assert(b[1] == 1)
assert(b[2] == 9)
assert(b[3] == 4)
assert(b[4] == 6)

local b = bernstein(polynomial(2,30,-57,27))
assert(#b == 4)
assert(b[1] ==  2)
assert(b[2] == 12)
assert(b[3] ==  3)
assert(b[4] ==  2)

local b = bernstein(polynomial(1,6,-12,7))
assert(#b == 4)
assert(b[1] == 1)
assert(b[2] == 3)
assert(b[3] == 1)
assert(b[4] == 2)



