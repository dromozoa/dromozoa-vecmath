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
local bezier_clipping = require "dromozoa.vecmath.bezier_clipping"

local b1 = vecmath.bezier({-240,0}, {-80,80}, {80,-160}, {240,80})
local b2 = vecmath.bezier({-50,-150}, {-25,200}, {150,300}, {150,150})

local z = math.cos(math.pi / 4)
local b3 = vecmath.bezier({-200,-200,1}, {200*z,-200*z,z}, {200,200,1})

bezier_clipping(b1, b2, {})
