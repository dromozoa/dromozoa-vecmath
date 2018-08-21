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

local function fat_line(b)
  local p = point2()
  local q = point2()
  local u = vector2()
  local v = vector2()

  local n = bezier.size(b)
  b:get(1, p)
  b:get(n, q)
  u:sub(q, p)
  u:normalize()

  local d_min = 0
  local d_max = 0
  for i = 2, n - 1 do
    b:get(i, q)
    v:sub(q, p)
    local d = v:cross(u)
    if d_min > d then
      d_min = d
    end
    if d_max < d then
      d_max = d
    end
  end

  if not b:is_rational() then
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

local function explicit_intersection(Q, d, t_min, t_max)
  local p3 = point2(0, d)
  local v1 = vector2()
  local v2 = vector2(1, 0)
  local v3 = vector2()

  for i = 1, #Q do
    local p1 = Q[i]
    local p2 = Q[i + 1]
    if not p2 then
      p2 = Q[1]
    end
    v1:sub(p2, p1)
    v3:sub(p3, p1)
    local d = v1:cross(v2)
    local a_min = v3:cross(v2) / d
    local b_min = v3:cross(v1) / d
    if 0 <= a_min and a_min <= 1 and 0 <= b_min and b_min <= 1 then
      if not t_min or t_min > b_min then
        t_min = b_min
      end
      if not t_max or t_max < b_min then
        t_max = b_min
      end
    end
  end

  return t_min, t_max
end

local function bezier_clipping(b1, b2)
  local p, u, d_min, d_max = fat_line(b2)

  local q = point2()
  local v = vector2()

  local n = bezier.size(b1)

  if bezier.is_rational(b1) then
    -- TODO impl
  else
    local P = {}
    for i = 1, n do
      b1:get(i, q)
      v:sub(q, p)
      local d = v:cross(u)
      P[i] = point2((i - 1) / (n - 1), d)
    end

    local Q = quickhull(P, {})

    local t_min, t_max = explicit_intersection(Q, d_min)
    t_min, t_max = explicit_intersection(Q, d_max, t_min, t_max)
    return t_min, t_max
  end
end

local function iterate(b1, b2, u1, u2, u3, u4)
  local t1, t2 = bezier_clipping(b1, b2)
  if t1 then
    local t = t2 - t1
    if t < 0.8 then
      local u = u2 - u1
      u1 = u1 + u * t1
      u2 = u2 + u * t2
      bezier.clip(b1, t1, t2)
    end
  end

  local t3, t4 = bezier_clipping(b2, b1)
  if t3 then
    local t = t4 - t3
    if t < 0.8 then
      local u = u4 - u3
      u4 = u3 + u * t3
      u3 = u4 + u * t4
      bezier.clip(b2, t3, t4)
    end
  end
  return u1, u2, u3, u4
end

return function (b1, b2, result)
  return iterate(b1, b2, 0, 1, 0, 1)
end
