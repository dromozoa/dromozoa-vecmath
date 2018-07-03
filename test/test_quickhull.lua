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
local quickhull = require "dromozoa.vecmath.quickhull"

local point2 = vecmath.point2

local verbose = os.getenv "VERBOSE" == "1"
local epsilon = 1e-9

-- circle

local P = {}
local R = {}

local m = 64
local n = 8
for i = 1, m do
  local t = i / m * math.pi * 2
  local c = math.cos(t)
  local s = math.sin(t)
  for j = 1, n do
    local u = j / n * 300
    P[#P + 1] = point2(c * u, s * u)
  end
  local t = - ((i - 1) / m + 0.5) * math.pi * 2
  R[#R + 1] = point2(math.cos(t) * 300, math.sin(t) * 300)
end

local Q = quickhull(P, {})

assert(#Q == #R)
for i = 1, #Q do
  if verbose then
    print(Q[i], R[i])
  end
  assert(Q[i]:epsilon_equals(R[i], epsilon))
end

-- horizontal line

local P = { {0,0}, {1,0}, {2,0}, {3,0}, {4,0} }
local Q = quickhull(P, {})
assert(#Q == 2)
assert(point2.equals(Q[1], {0,0}))
assert(point2.equals(Q[2], {4,0}))

-- vertical line

local P = { {0,0}, {0,1}, {0,2}, {0,3}, {0,4} }
local Q = quickhull(P, {})
assert(#Q == 2)
assert(point2.equals(Q[1], {0,0}))
assert(point2.equals(Q[2], {0,4}))

-- same points
local P = { {0,0}, {0,0}, {0,0} }
local Q = quickhull(P, {})
assert(#Q == 1)
assert(point2.equals(Q[1], {0,0}))

-- two points
local P = { {0,0}, {1,1} }
local Q = quickhull(P, {})
assert(#Q == 2)
assert(point2.equals(Q[1], {0,0}))
assert(point2.equals(Q[2], {1,1}))

-- triangle1
local P = { {0,0}, {1,1}, {1,0} }
local Q = quickhull(P, {})
assert(#Q == 3)
assert(point2.equals(Q[1], {0,0}))
assert(point2.equals(Q[2], {1,1}))
assert(point2.equals(Q[3], {1,0}))

-- triangle2
local P = { {0,0}, {1,1}, {0,1} }
local Q = quickhull(P, {})
assert(#Q == 3)
assert(point2.equals(Q[1], {0,0}))
assert(point2.equals(Q[2], {0,1}))
assert(point2.equals(Q[3], {1,1}))
