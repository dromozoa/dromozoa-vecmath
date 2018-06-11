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

local vector4 = require "dromozoa.vecmath.vector4"

local verbose = os.getenv "VERBOSE" == "1"

assert(vector4{1,2,3} :equals {1,2,3,0})

local data = assert(loadfile "test/vector4d.lua")()

local v = vector4()
local v1 = vector4(data[1])
local v2 = vector4(data[2])

assert(v1:length() == data.length)
assert(v1:length_squared() == data.length_squared)

assert(v1:dot(v2) == data.dot)
assert(v2:dot(v1) == data.dot)

assert(v:normalize(v1):equals(data.normalize))
assert(v:set(v1):normalize():equals(data.normalize))

assert(v1:angle(v2) == data.angle)
assert(v2:angle(v1) == data.angle)

