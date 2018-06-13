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

local quat4 = require "dromozoa.vecmath.quat4"

local epsilon = 1e-9

local data = assert(loadfile "test/quat.lua")()
local q1 = quat4(data[1])
local q2 = quat4(data[2])

assert(quat4():conjugate(q1):equals(data.conjugate))
assert(quat4(q1):conjugate():equals(data.conjugate))
assert(quat4():mul(q1, q2):equals(data.mul))
assert(quat4(q1):mul(q2):equals(data.mul))
assert(quat4():mul_inverse(q1, q2):epsilon_equals(data.mul_inverse, epsilon))
assert(quat4(q1):mul_inverse(q2):epsilon_equals(data.mul_inverse, epsilon))
assert(quat4():inverse(q1):epsilon_equals(data.inverse, epsilon))
assert(quat4(q1):inverse():epsilon_equals(data.inverse, epsilon))
assert(quat4():normalize(q1):epsilon_equals(data.normalize, epsilon))
assert(quat4(q1):normalize():epsilon_equals(data.normalize, epsilon))
