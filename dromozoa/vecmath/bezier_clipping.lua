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

local function clip_min(H, d, t_min, t_max)
  local n = #H

  local p = H[n]
  local pt = p[1]
  local pd = p[2]

  for i = 1, n do
    local q = H[i]
    local qt = q[1]
    local qd = q[2]

    if pd >= d then
      if not t_min or t_min > pt then
        t_min = pt
      end
      if not t_max or t_max < pt then
        t_max = pt
      end
      if qd < d then
        local a = (pd - d) / (pd - qd)
        local t = pt * (1 - a) + qt * a
        if not t_max or t_max < t then
          t_max = t
        end
      end
    else
      if qd > d then
        local a = (pd - d) / (pd - qd)
        local t = pt * (1 - a) + qt * a
        if not t_min or t_min > t then
          t_min = t
        end
      end
    end

    p = q
    pt = qt
    pd = qd
  end

  return t_min, t_max
end

local function clip_max(H, d, t_min, t_max)
  local n = #H

  local p = H[n]
  local pt = p[1]
  local pd = p[2]

  for i = 1, n do
    local q = H[i]
    local qt = q[1]
    local qd = q[2]

    if pd <= d then
      if not t_min or t_min > pt then
        t_min = pt
      end
      if not t_max or t_max < pt then
        t_max = pt
      end
      if qd > d then
        local a = (pd - d) / (pd - qd)
        local t = pt * (1 - a) + qt * a
        if not t_min or t_min > t then
          t_min = t
        end
      end
    else
      if qd < d then
        local a = (pd - d) / (pd - qd)
        local t = pt * (1 - a) + qt * a
        if not t_max or t_max < t then
          t_max = t
        end
      end
    end

    p = q
    pt = qt
    pd = qd
  end

  return t_min, t_max
end

local function bezier_clipping(b1, b2)
  local A, B, C, d_min, d_max = fat_line(b2)

  local n = bezier.size(b1)

  print("d", d_min, d_max)

  if bezier.is_rational(b1) then
    local P = {}
    local q = point3()
    for i = 1, n do
      b1:get(i, q)
      local w = q[3]
      local x = q[1] / w
      local y = q[2] / w
      local d1 = w * (A * x + B * y + C - d_min)
      local d2 = w * (A * x + B * y + C + d_max)
      local t = (i - 1) / (n - 1)
      P[#P + 1] = point2(t, d1)
      P[#P + 2] = point2(t, d2)
    end
    local H = quickhull(P, {})
    return explicit_intersection(H, 0)
  else
    local P = {}
    local q = point2()
    for i = 1, n do
      b1:get(i, q)
      local d = A * q[1] + B * q[2] + C
      P[i] = point2((i - 1) / (n - 1), d)
    end
    local H = quickhull(P, {})

    local t_min, t_max = clip_min(H, d_min)
    print("t", t_min, t_max)
    local u_min, u_max = clip_max(H, d_max)
    print("u", u_min, u_max)
    -- local t_min, t_max = clip_max(H, d_max, clip_min(H, d_min))
    -- print("t", t_min, t_max)

    local t_min, t_max = explicit_intersection(H, d_min, explicit_intersection(H, d_max))
    print("T", t_min, t_max)

    return explicit_intersection(H, d_min, explicit_intersection(H, d_max))
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
  -- local t3, t4 = bezier_clipping(b2, b1)
  -- if t3 then
  --   local t = t4 - t3
  --   if t < 0.8 then
  --     local u = u4 - u3
  --     u4 = u3 + u * t3
  --     u3 = u4 + u * t4
  --     bezier.clip(b2, t3, t4)
  --   end
  -- end
  return u1, u2, u3, u4
end

return function (b1, b2, result)
  return iterate(b1, b2, 0, 1, 0, 1)
end
