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

local point3 = require "dromozoa.vecmath.point3"
local vector3 = require "dromozoa.vecmath.vector3"
local vector4 = require "dromozoa.vecmath.vector4"

local verbose = os.getenv "VERBOSE" == "1"

local function test(n, class)
  assert(class() :equals {0,0,0,0})
  assert(class(1,2,3,4) :equals {1,2,3,4})
  assert(class{1,2,3,4} :equals {1,2,3,4})

  local t = class(1,2,3,4)
  assert(t:set() :equals {0,0,0,0})
  assert(t:set(2,3,4,5) :equals {2,3,4,5})
  assert(t:set{3,4,5,6} :equals {3,4,5,6})

  local t1 = class(1,2,3,4)
  local t2 = class(2,3,4,5)
  assert(t1:get(t2) == t1)
  assert(t1:equals(t2))

  local t1 = class(1,2,3,4)
  local t2 = class(2,3,4,5)
  local t3 = class(3,4,5,6)
  assert(t2:add(t3)     :equals {5,7,9,11})
  assert(t1:add(t2, t3) :equals {8,11,14,17})

  local t1 = class(3,4,5,6)
  local t2 = class(2,3,4,5)
  local t3 = class(1,2,3,4)
  assert(t1:sub(t2)     :equals {1,1,1,1})
  assert(t1:sub(t2, t3) :equals {1,1,1,1})

  local t1 = class( 0,-1,-1,-1)
  local t2 = class(-1, 0,-1,-1)
  assert(t1:negate()   :equals {0,1,1,1})
  assert(t1:negate(t2) :equals {1,0,1,1})

  local t = class(1,2,3,4)
  assert(t:scale(2) :equals {2,4,6,8})
  assert(t:scale(2, {4,3,2,1}) :equals {8,6,4,2})

  local t = class(1,2,3,4)
  assert(t:scale_add(3, {1,1,1,1}) :equals {4,7,10,13})
  assert(t:scale_add(3, {4,3,2,1}, {1,1,1,1}) :equals {13,10,7,4})

  local t = class(1,1,1,1)
  assert(t:epsilon_equals({0,0,0,0}, 1))
  assert(t:epsilon_equals({1,1,1,1}, 1))
  assert(t:epsilon_equals({2,2,2,2}, 1))
  assert(not t:epsilon_equals({3,3,3,3}, 1))

  local t = class()
  assert(t:clamp(1, 5, {0,6,3,3}) :equals {1,5,3,3})
  assert(t:clamp(2, 4) :equals {2,4,3,3})

  local t = class()
  assert(t:clamp_min(1, {0,6,3,3}) :equals {1,6,3,3})
  assert(t:clamp_min(2) :equals {2,6,3,3})

  local t = class()
  assert(t:clamp_max(5, {0,6,3,3}) :equals {0,5,3,3})
  assert(t:clamp_max(4) :equals {0,4,3,3})

  local t = class()
  assert(t:absolute{2,-1,-1,-1} :equals {2,1,1,1})
  local t = class(2,-1,-1,-1)
  assert(t:absolute() :equals {2,1,1,1})

  local t = class(1,2,3,4)
  assert(t.x == 1)
  assert(t.y == 2)
  if n > 2 then
    assert(t.z == 3)
    if n > 3 then
      assert(t.w == 4)
    end
  end

  t.x = 2
  t.y = 3
  if n > 2 then
    t.z = 4
    if n > 3 then
      t.w = 5
    end
  end
  assert(t :equals {2,3,4,5})

  t[1] = 3
  t[2] = 4
  if n > 2 then
    t[3] = 5
    if n > 3 then
      t[4] = 6
    end
  end
  assert(t :equals {3,4,5,6})

  local s = tostring(t)
  if verbose then
    print(s)
  end
  if n == 2 then
    assert(s == "(3, 4)")
  elseif n == 3 then
    assert(s == "(3, 4, 5)")
  elseif n == 4 then
    assert(s == "(3, 4, 5, 6)")
  end

  local t = class(1,2,3,4)
  t[n] = nil
  assert(not t[n])
end

test(3, point3)
test(3, vector3)
test(4, vector4)
