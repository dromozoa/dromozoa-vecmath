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

local point2 = require "dromozoa.vecmath.point2"
local vector2 = require "dromozoa.vecmath.vector2"

local bezier = require "dromozoa.vecmath.bezier"
local quickhull = require "dromozoa.vecmath.quickhull"

local epsilon = 1e-9

local function fat_line(b, p, u)
  local n = bezier.size(b)
  local q = point2()
  local v = vector2()

  bezier.get(b, 1, p)
  bezier.get(b, n, q)
  vector2.sub(u, q, p)
  vector2.normalize(u)

  local d_min = 0
  local d_max = 0
  for i = 2, n - 1 do
    bezier.get(b, i, q)
    vector2.sub(v, q, p)
    local d = vector2.cross(v, u)
    if d_min > d then
      d_min = d
    end
    if d_max < d then
      d_max = d
    end
  end

  if not bezier.is_rational(b) then
    if n == 3 then
      d_min = d_min / 2
      d_max = d_max / 2
    elseif n == 4 then
      if d_min == 0 then
        d_max = d_max * (3 / 4)
      elseif d_max == 0 then
        d_min = d_min * (3 / 4)
      else
        d_min = d_min * (4 / 9)
        d_max = d_max * (4 / 9)
      end
    end
  end

  return p, u, d_min, d_max
end

local function bezier_clipping(b1, b2)
  local p, u, d_min, d_max = fat_line(b2, point2(), vector2())

  local n = bezier.size(b1)
  local q = point2()
  local v = vector2()

  print("d_min", d_min)
  print("d_max", d_max)

  if bezier.is_rational(b1) then
    -- TODO impl
  else
    local P = {}
    for i = 1, n do
      bezier.get(b1, i, q)
      vector2.sub(v, q, p)
      local d = vector2.cross(v, u)
      P[#P + 1] = point2((i - 1) / (n - 1), d)
    end

    local p3 = point2(0, d_min)
    local p4 = point2(0, d_max)
    local v1 = vector2()
    local v2 = vector2(1, 0)
    local v3 = vector2()

    local t_min
    local t_max
    local Q = quickhull(P, {})
    for i = 1, #Q do
      local p1 = Q[i]
      local p2 = Q[i + 1]
      if not p2 then
        p2 = Q[1]
      end
      print("p1", tostring(p1))
      print("p2", tostring(p2))
      vector2.sub(v1, p2, p1)
      local d = vector2.cross(v1, v2)
      vector2.sub(v3, p3, p1)
      local a_min = vector2.cross(v3, v2) / d
      local b_min = vector2.cross(v3, v1) / d
      vector2.sub(v3, p4, p1)
      local a_max = vector2.cross(v3, v2) / d
      local b_max = vector2.cross(v3, v1) / d
      if 0 <= a_min and a_min <= 1 and 0 <= b_min and b_min <= 1 then
        print("b_min", b_min)
        if not t_min or t_min > b_min then
          t_min = b_min
        end
        if not t_max or t_max < b_min then
          t_max = b_min
        end
      end
      if 0 <= a_max and a_max <= 1 and 0 <= b_max and b_max <= 1 then
        print("b_max", b_max)
        if not t_min or t_min > b_max then
          t_min = b_max
        end
        if not t_max or t_max < b_max then
          t_max = b_max
        end
      end
      print("t_min", t_min)
      print("t_max", t_max)
    end

    return t_min, t_max
  end
end

local function iterate(b1, b2, u1, u2, u3, u4)
  local t3, t4 = bezier_clipping(b1, b2)
  if t3 then
    -- 0.1 .. 0.5 / 0.4
    local t = t4 - t3
    if t < 0.8 then
      local u = u4 - u3
      -- clip b2
      u3 = u3 + u * t3
      u4 = u3 + u * t4
      -- local b3 = b2:eval(t3, point3())

    end
  end
end

return function (b1, b2, result)
  return iterate(b1, b2, 0, 1, 0, 1)
end
