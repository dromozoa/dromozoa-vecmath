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

local p = polynomial(bernstein(1,3,4,6,8))
assert(#p == 5)
assert(p[1] ==  1)
assert(p[2] ==  8)
assert(p[3] == -6)
assert(p[4] ==  8)
assert(p[5] == -3)

local b = p:get(bernstein(1,1,1,1,1,1,1,1))
assert(#b == 5)
assert(b[1] == 1)
assert(b[2] == 3)
assert(b[3] == 4)
assert(b[4] == 6)
assert(b[5] == 8)

-- 7*binomial(3,0)*(1-t)^3 + 11*binomial(3,1)*(1-t)^2*t + 13*binomial(3,2)*(1-t)*t^2 + 19*binomial(3,3)*t^3
local b = bernstein(7,11,13,19)

-- 7 11 13 19
-- 7 9 12 16 | 19
-- 7 9 10.5 14 | 16 19
-- 7 9 10.5 12.25 | 14 16 19
-- 7 9 10.5 12.25 | 12.25 14 16 19

local v, b1, b2 = b:eval(0.5, bernstein(), bernstein())
assert(v == 12.25)
assert(b1[1] == 7)
assert(b1[2] == 9)
assert(b1[3] == 10.5)
assert(b1[4] == 12.25)
assert(b2[1] == 12.25)
assert(b2[2] == 14)
assert(b2[3] == 16)
assert(b2[4] == 19)

local v, b1, b2 = b:eval(0.5, bernstein())
assert(v == 12.25)
assert(b1[1] == 7)
assert(b1[2] == 9)
assert(b1[3] == 10.5)
assert(b1[4] == 12.25)
assert(not b2)

-- 7 11 13 19
-- 9 12 16 | 19
-- 10.5 14 | 16 19
-- 12.25 | 14 16 19
-- 12.25 14 16 19

local v, b1, b2 = b:eval(0.5, nil, bernstein())
if verbose then
  print(table.concat(b2, " "))
end

assert(v == 12.25)
assert(not b1)
assert(b2[1] == 12.25)
assert(b2[2] == 14)
assert(b2[3] == 16)
assert(b2[4] == 19)

-- 7 11 13 19
-- 7 10 12.5 17.5 | 19
-- 7 10 11.875 16.25 | 17.5 19
-- 7 10 11.875 15.15625 | 16.25 17.5 19
-- 7 10 11.875 15.15625 | 15.15625 16.25 17.5 19

local v, b1, b2 = b:eval(0.75, bernstein(1,1,1,1,1,1,1,1), bernstein(1,1,1,1,1,1,1,1))
assert(v == 15.15625)
assert(#b1 == 4)
assert(b1[1] == 7)
assert(b1[2] == 10)
assert(b1[3] == 11.875)
assert(b1[4] == 15.15625)
assert(#b2 == 4)
assert(b2[1] == 15.15625)
assert(b2[2] == 16.25)
assert(b2[3] == 17.5)
assert(b2[4] == 19)

local v, b1, b2 = b:eval(0.75, nil, bernstein(1,1,1,1,1,1,1,1))
assert(v == 15.15625)
assert(not b1)
assert(#b2 == 4)
assert(b2[1] == 15.15625)
assert(b2[2] == 16.25)
assert(b2[3] == 17.5)
assert(b2[4] == 19)

local b1 = bernstein(1,1,1,1,1,1,1,1):reverse(b)
assert(#b1 == 4)
assert(b1[1] == 19)
assert(b1[2] == 13)
assert(b1[3] == 11)
assert(b1[4] == 7)
local b2 = bernstein(b):reverse()
assert(#b2 == 4)
assert(b2[1] == 19)
assert(b2[2] == 13)
assert(b2[3] == 11)
assert(b2[4] == 7)

local b = bernstein(0, 4, 6, 12):elevate()
if verbose then
  print(table.concat(b, " "))
end
assert(#b == 5)
assert(b[1] == 0)
assert(b[2] == 3)
assert(b[3] == 5)
assert(b[4] == 7.5)
assert(b[5] == 12)

local b = bernstein(1,1,1,1,1,1,1,1,1):elevate{12, 6, 4, 0}
if verbose then
  print(table.concat(b, " "))
end
assert(#b == 5)
assert(b[1] == 12)
assert(b[2] == 7.5)
assert(b[3] == 5)
assert(b[4] == 3)
assert(b[5] == 0)

-- 7*binomial(3,0)*(1-t)^3 + 11*binomial(3,1)*(1-t)^2*t + 13*binomial(3,2)*(1-t)*t^2 + 19*binomial(3,3)*t^3
-- 12*binomial(2,0)*(1-t)^2 + 6*binomial(2,1)*(1-t)*t + 18*binomial(2,2)*t^2
local b1 = bernstein(7,11,13,19)
local b2 = bernstein(b1):deriv()
local p1 = polynomial(b1)
local p2 = polynomial(p1):deriv()
local b3 = bernstein(p2)
if verbose then
  print(table.concat(b2, " "))
  print(table.concat(b3, " "))
end
assert(#b2 == 3)
assert(b2[1] == 12)
assert(b2[2] == 6)
assert(b2[3] == 18)

assert(#b2 == #b3)
for i = 1, #b3 do
  assert(b2[i] == b3[i])
end

local b4 = bernstein():deriv(b1)
local b5 = bernstein(1,1,1,1,1,1,1,1):deriv(b1)

assert(#b4 == #b3)
assert(#b5 == #b3)
for i = 1, #b3 do
  assert(b4[i] == b3[i])
  assert(b5[i] == b3[i])
end
