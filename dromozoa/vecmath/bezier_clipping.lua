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

  local n = b:size()
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

local function clip_both(H, d_min, d_max)
  local t1 = 1
  local t2 = 0

  local n = #H
  local p = H[n]
  local pt = p[1]
  local pd = p[2]

  for i = 1, n do
    local q = H[i]
    local qt = q[1]
    local qd = q[2]

    if d_min <= pd and pd <= d_max then
      if t1 > pt then
        t1 = pt
      end
      if t2 < pt then
        t2 = pt
      end
    end

    local d = pd - qd

    -- TODO use clockwise
    local a = (pd - d_min) / d
    if 0 < a and a < 1 then
      local t = pt * (1 - a) + qt * a
      if t1 > t then
        t1 = t
      end
      if t2 < t then
        t2 = t
      end
    end

    -- TODO use clockwise
    local a = (pd - d_max) / d
    if 0 < a and a < 1 then
      local t = pt * (1 - a) + qt * a
      if t1 > t then
        t1 = t
      end
      if t2 < t then
        t2 = t
      end
    end

    pt = qt
    pd = qd
  end

  if t1 <= t2 then
    return t1, t2
  end
end

local function clip_min(H)
  local t1 = 1
  local t2 = 0

  local n = #H
  local p = H[n]
  local pt = p[1]
  local pd = p[2]

  for i = 1, n do
    local q = H[i]
    local qt = q[1]
    local qd = q[2]

    if pd >= 0 then
      if t1 > pt then
        t1 = pt
      end
      if t2 < pt then
        t2 = pt
      end
    end

    -- TODO use clockwise
    local a = pd / (pd - qd)
    if 0 < a and a < 1 then
      local t = pt * (1 - a) + qt * a
      if t1 > t then
        t1 = t
      end
      if t2 < t then
        t2 = t
      end
    end

    pt = qt
    pd = qd
  end

  if t1 <= t2 then
    return t1, t2
  end
end

local function clip_max(H)
  local t1 = 1
  local t2 = 0

  local n = #H
  local p = H[n]
  local pt = p[1]
  local pd = p[2]

  for i = 1, n do
    local q = H[i]
    local qt = q[1]
    local qd = q[2]

    if pd <= 0 then
      if t1 > pt then
        t1 = pt
      end
      if t2 < pt then
        t2 = pt
      end
    end

    -- TODO use clockwise
    local a = pd / (pd - qd)
    if 0 < a and a < 1 then
      local t = pt * (1 - a) + qt * a
      if t1 > t then
        t1 = t
      end
      if t2 < t then
        t2 = t
      end
    end

    pt = qt
    pd = qd
  end

  if t1 <= t2 then
    return t1, t2
  end
end

local function clip(b1, b2)
  local A, B, C, d_min, d_max = fat_line(b2)

  local n = b1:size()
  if b1:is_rational() then
    local C1 = C + d_min
    local C2 = C - d_max
    local P1 = {}
    local P2 = {}
    local p = point3()
    for i = 1, n do
      b1:get(i, p)
      local t = (i - 1) / (n - 1)
      local u = A * p[1] + B * p[2]
      local w = p[3]
      P1[i] = point2(t, u + w * C1)
      P2[i] = point2(t, u + w * C2)
    end
    local H = quickhull(P1, {})
    local t1, t2 = clip_min(H)
    if not t1 then
      return
    end
    quickhull(P2, H)
    local t3, t4 = clip_max(H)
    if not t3 then
      return
    end
    if t2 - t1 < t4 - t3 then
      return t1, t2
    else
      return t3, t4
    end
  else
    local P = {}
    local p = point2()
    for i = 1, n do
      b1:get(i, p)
      P[i] = point2((i - 1) / (n - 1), A * p[1] + B * p[2] + C)
    end
    local H = quickhull(P, {})
    return clip_both(H, d_min, d_max)
  end
end

local function iterate(b1, b2, u1, u2, u3, u4, result)
  local U1 = result[1]
  local U2 = result[2]

  assert(0 <= u1 and u1 <= 1)
  assert(0 <= u2 and u2 <= 1)
  assert(u1 < u2 or math.abs(u2 - u1) < epsilon)
  assert(0 <= u3 and u3 <= 1)
  assert(0 <= u4 and u4 <= 1)
  assert(u3 < u4 or math.abs(u4 - u3) < epsilon)

  local m = (b1:size() - 1) * (b2:size() - 1)
  if #U1 > m then
    return result
  end

  if math.abs(u2 - u1) < epsilon and math.abs(u4 - u3) < epsilon then
    U1[#U1 + 1] = (u1 + u2) / 2
    U2[#U2 + 1] = (u3 + u4) / 2
    return result
  end

  local t1, t2 = clip(b1, b2)
  if not t1 then
    return result
  end
  assert(0 <= t1 and t1 <= 1)
  assert(0 <= t2 and t2 <= 1)
  local r1 = t2 - t1
  local s1 = u2 - u1
  u2 = u1 + s1 * t2
  u1 = u1 + s1 * t1
  b1:clip(t1, t2)

  local t3, t4 = clip(b2, b1)
  if not t3 then
    return result
  end
  assert(0 <= t3 and t3 <= 1)
  assert(0 <= t4 and t4 <= 1)
  local r2 = t4 - t3
  local s2 = u4 - u3
  u4 = u3 + s2 * t4
  u3 = u3 + s2 * t3
  b2:clip(t3, t4)

  if r1 > 0.8 and r2 > 0.8 then
    if s1 > s2 then
      local b3 = bezier(b1):clip(0, 0.5)
      local b4 = bezier(b2)
      local b5 = bezier(b1):clip(0.5, 1)
      local b6 = bezier(b2)
      local u5 = (u1 + u2) / 2
      iterate(b3, b4, u1, u5, u3, u4, result)
      iterate(b5, b6, u5, u2, u3, u4, result)
      return result
    else
      local b3 = bezier(b1)
      local b4 = bezier(b2):clip(0, 0.5)
      local b5 = bezier(b1)
      local b6 = bezier(b2):clip(0.5, 1)
      local u5 = (u3 + u4) / 2
      iterate(b3, b4, u1, u2, u3, u5, result)
      iterate(b5, b6, u1, u2, u5, u4, result)
      return result
    end
  else
    iterate(b1, b2, u1, u2, u3, u4, result)
    return result
  end
end

return function (b1, b2, result)
  return iterate(b1, b2, 0, 1, 0, 1, result)
end
