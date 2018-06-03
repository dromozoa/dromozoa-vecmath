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

local tuple3 = require "dromozoa.vecmath.tuple3"

local verbose = os.getenv "VERBOSE" == "1"

local t1 = tuple3()
local t2 = tuple3(1, 2, 3)
local t3 = tuple3 { 4, 5, 6 }

assert(t1:equals { 0, 0, 0 })
assert(t2:equals { 1, 2, 3 })
assert(t3:equals { 4, 5, 6 })

assert(t1:equals { 0, 0, 0 })
assert(t2:equals { 1, 2, 3 })
assert(t3:equals { 4, 5, 6 })

assert(t2:add(t3):equals { 5, 7, 9 })
assert(t1:add(t2, t3):equals { 9, 12, 15 })

assert(t2:sub(t3):equals { 1, 2, 3 })
assert(t1:sub(t3, t2):equals { 3, 3, 3 })

local t = tuple3()
assert(t:negate { -1, 0, 1 }:equals { 1, 0, -1 })
assert(t:negate():equals { -1, 0, 1 })

local t = tuple3()
assert(t:clamp(1, 5, { 0, 3, 6 }):equals { 1, 3, 5 })
assert(t:clamp(2, 4):equals { 2, 3, 4 })

local t = tuple3()
assert(t:clamp_min(1, { 0, 2, 4 }):equals { 1, 2, 4 })
assert(t:clamp_min(3):equals { 3, 3, 4 })

local t = tuple3()
assert(t:clamp_max(3, { 0, 2, 4 }):equals { 0, 2, 3 })
assert(t:clamp_max(1):equals { 0, 1, 1 })

local t = tuple3()
assert(t:absolute { -1, 0, 1 }:equals { 1, 0, 1 })
assert(t:set( -1, 0, 1 ):absolute() :equals { 1, 0, 1 })

local t = tuple3(1, 2, 3)
assert(t.x == 1)
assert(t.y == 2)
assert(t.z == 3)

t.x = 2
t.y = 3
t.z = 4
assert(t:equals { 2, 3, 4 })

t[1] = 3
t[2] = 4
t[3] = 5
assert(t:equals { 3, 4, 5 })

local s = tostring(t)
if verbose then
  print(s)
end
assert(s == "(3,4,5)")
