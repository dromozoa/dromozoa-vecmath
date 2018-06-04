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

local verbose = os.getenv "VERBOSE" == "1"

local m = matrix3(1, 2, 3, 4, 5, 6, 7, 8, 9)
local s = tostring(m)
if verbose then
  print(s)
end
assert(s == [[
1, 2, 3
4, 5, 6
7, 8, 9]])

assert(m:set_identity() :equals {1,0,0,0,1,0,0,0,1})
local s = tostring(m)
if verbose then
  print(s)
end
assert(s == [[
1, 0, 0
0, 1, 0
0, 0, 1]])



