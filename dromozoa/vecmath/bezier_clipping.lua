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
local point3 = require "dromozoa.vecmath.point3"
local vector2 = require "dromozoa.vecmath.vector2"

local bezier = require "dromozoa.vecmath.bezier"
local quickhull = require "dromozoa.vecmath.quickhull"

local epsilon = 1e-9

local function fat_line(b)
  local p = point2()
  local q = point2()
  local v = vector2()

  local n = bezier.size(b)
  b:get(1, p)
  b:get(n, q)
  v:sub(q, p)
  v:normalize()

  local x = v[1]
  local A = v[2]
  local B = -x
  local C = x * p[2] - A * p[1]

  local d_min = 0
  local d_max = 0
  for i = 2, n - 1 do
    b:get(i, q)
    local d = A * q[1] + B * q[2] + C
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

  return A, B, C, d_min, d_max
end

local function explicit_intersection(H, d, t_min, t_max)
  local n = #H
  local p = H[n]
  local pd = p[2]
  for i = 1, n do
    local q = H[i]
    local qd = q[2]
    if pd >= d and qd < d then
      local a = (pd - d) / (pd - qd)
      local t = p[1] * (1 - a) + q[1] * a
      if not t_max or t_max < t then
        t_max = t
      end
    elseif pd <= d and qd > d then
      local a = (pd - d) / (pd - qd)
      local t = p[1] * (1 - a) + q[1] * a
      if not t_min or t_min > t then
        t_min = t
      end
    end
    p = q
    pd = qd
  end
  return t_min, t_max
end

local function clip(H, d_min, d_max)
  local t_min = 1
  local t_max = 0

  local n = #H
  local p = H[n]
  local pt = p[1]
  local pd = p[2]

  for i = 1, n do
    local q = H[i]
    local qt = q[1]
    local qd = q[2]

    if d_min <= pd and pd <= d_max then
      if t_min > pt then
        t_min = pt
      end
      if t_max < pt then
        t_max = pt
      end
    end

    local c = pd - qd
    local a = (pd - d_min) / c
    local b = (pd - d_max) / c

    -- TODO use clockwise
    if 0 < a and a < 1 then
      local t = pt * (1 - a) + qt * a
      if t_min > t then
        t_min = t
      end
      if t_max < t then
        t_max = t
      end
    end

    -- TODO use clockwise
    if 0 < b and b < 1 then
      local t = pt * (1 - b) + qt * b
      if t_min > t then
        t_min = t
      end
      if t_max < t then
        t_max = t
      end
    end

    pt = qt
    pd = qd
  end

  if t_min <= t_max then
    return t_min, t_max
  end
end

local function clip_min(H)
  local t_min = 1
  local t_max = 0

  local n = #H
  local p = H[n]
  local pt = p[1]
  local pd = p[2]

  for i = 1, n do
    local q = H[i]
    local qt = q[1]
    local qd = q[2]

    if pd >= 0 then
      if t_min > pt then
        t_min = pt
      end
      if t_max < pt then
        t_max = pt
      end
    end

    local a = pd / (pd - qd)

    -- TODO use clockwise
    if 0 < a and a < 1 then
      local t = pt * (1 - a) + qt * a
      if t_min > t then
        t_min = t
      end
      if t_max < t then
        t_max = t
      end
    end

    pt = qt
    pd = qd
  end

  if t_min <= t_max then
    return t_min, t_max
  end
end

local function clip_max(H)
  local t_min = 1
  local t_max = 0

  local n = #H
  local p = H[n]
  local pt = p[1]
  local pd = p[2]

  for i = 1, n do
    local q = H[i]
    local qt = q[1]
    local qd = q[2]

    if pd <= 0 then
      if t_min > pt then
        t_min = pt
      end
      if t_max < pt then
        t_max = pt
      end
    end

    local a = pd / (pd - qd)

    -- TODO use clockwise
    if 0 < a and a < 1 then
      local t = pt * (1 - a) + qt * a
      if t_min > t then
        t_min = t
      end
      if t_max < t then
        t_max = t
      end
    end

    pt = qt
    pd = qd
  end

  if t_min <= t_max then
    return t_min, t_max
  end
end

local function bezier_clipping(b1, b2)
  local A, B, C, d_min, d_max = fat_line(b2)

  local n = bezier.size(b1)

  if bezier.is_rational(b1) then
    local C_min = C + d_min
    local C_max = C - d_max
    local P1 = {}
    local P2 = {}
    local p = point3()
    for i = 1, n do
      b1:get(i, p)
      local t = (i - 1) / (n - 1)
      local u = A * p[1] + B * p[2]
      local w = p[3]
      P1[i] = point2(t, u + w * C_min)
      P2[i] = point2(t, u + w * C_max)
    end
    local H = quickhull(P1, {})
    local t_min, t_max = clip_min(H)
    if not t_min then
      return
    end
    quickhull(P2, H)
    local u_min, u_max = clip_max(H)
    if not u_min then
      return
    end
    if t_max - t_min < u_max - u_min then
      return t_min, t_max
    else
      return u_min, u_max
    end
  else
    local P = {}
    local p = point2()
    for i = 1, n do
      b1:get(i, p)
      P[i] = point2((i - 1) / (n - 1), A * p[1] + B * p[2] + C)
    end
    local H = quickhull(P, {})
    return clip(H, d_min, d_max)
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
