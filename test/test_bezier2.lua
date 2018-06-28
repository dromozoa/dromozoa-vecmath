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
local curve = require "dromozoa.vecmath.curve"

local point2 = vecmath.point2
local vector2 = vecmath.vector2

local verbose = os.getenv "VERBOSE" == "1"
local epsilon = 1e-9
local n = 64

local names = {
  "linear";
  "cubic";
  "quadratic";
  "cubic";
  "quartic";
  "quintic";
}

local function bezier(P, t)
  if #P == 2 then
    return point2():interpolate(P[1], P[2], t)
  else
    local Q = {}
    for i = 1, #P - 1 do
      Q[#Q + 1] = point2():interpolate(P[i], P[i + 1], t)
    end
    return bezier(Q, t)
  end
end

local function diff_bezier(P, t, order)
  if not order then
    order = #P - 1
  end
  if #P == 2 then
    return vector2():sub(P[2], P[1]):scale(order)
  else
    local Q = {}
    for i = 1, #P - 1 do
      Q[#Q + 1] = point2():interpolate(P[i], P[i + 1], t)
    end
    return diff_bezier(Q, t, order)
  end
end

local function check(P)
  local f = curve[names[#P] .. "_bezier"]
  local d = curve["diff_" .. names[#P] .. "_bezier"]
  for i = 1, #P do
    P[i] = point2(P[i])
  end
  for i = 0, n do
    local t = i / n
    local p = bezier(P, t)
    local q = f(P, t, point2())
    assert(p:epsilon_equals(q, epsilon))
    local u = diff_bezier(P, t)
    local v = d(P, t, vector2())
    if verbose then
      print(i, tostring(u), tostring(v))
    end
    assert(u:epsilon_equals(v, epsilon))
  end
end

check{ {0,0}, {1,1}, {2,0} }
check{ {1,1}, {1,1}, {2,0} }
check{ {0,0}, {1,1}, {1,1} }
check{ {1,1}, {1,1}, {1,1} }
check{ {0,0}, {1,0}, {0,0} }
check{ {0,0}, {1,0}, {0,1} }
check{ {0,0}, {1,0}, {1,1} }

check{ {0,0}, {1,1}, {2,-1}, {3, 0} }
check{ {1,1}, {1,1}, {2,-1}, {3, 0} }
check{ {0,0}, {1,1}, {2,-1}, {2,-1} }
check{ {1,1}, {1,1}, {2,-1}, {2,-1} }
check{ {0,0}, {1,0}, {0, 1}, {0, 0} }
check{ {0,0}, {1,0}, {0, 1}, {1, 0} }
check{ {0,0}, {1,0}, {0, 1}, {0, 1} }

check{ {0,0}, {1,1}, {2,0}, {3,1}, {4,0} }
check{ {0,0}, {1,1}, {2,0}, {1,-1}, {0,0} }
check{ {2,3}, {5,7}, {11,13}, {17,19}, {23,29} }
check{ {2,-3}, {-5,7}, {11,-13}, {-17,19}, {23,-29} }

check{ {0,0}, {1,1}, {2,0}, {3,1}, {4,0}, {5,1} }
check{ {0,0}, {1,1}, {2,0}, {1,-1}, {0,0}, {-1,-1} }
check{ {2,3}, {5,7}, {11,13}, {17,19}, {23,29}, {31,37} }
check{ {2,-3}, {-5,7}, {11,-13}, {-17,19}, {23,-29}, {-31,37} }
