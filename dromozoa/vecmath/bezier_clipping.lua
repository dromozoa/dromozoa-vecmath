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

-- by experimentations
local epsilon = 1e-11

local function fat_line(B1, B2)
  local n = B1:size()
  local p = point2()

  B1:get(1, p)
  local px = p[1]
  local py = p[2]

  B1:get(n, p)
  local a = p[2] - py
  local b = px - p[1]
  local c = -(a * px + b * py)

  if a == 0 and b == 0 then
    print "fat line is point"
    B2:get(1, p)
    local qx = p[1]
    local qy = p[2]
    B2:get(B2:size(), p)
    local ux = p[1] - qx
    local uy = p[2] - qy
    if ux == 0 and uy == 0 then
      a = 0
      b = 0
      c = 0
    else
      ux, uy = -uy, ux
      a = uy
      b = -ux
      c = -uy * px + ux * py
      print("F", a, b, c)
    end
  end

  local d_min = 0
  local d_max = 0
  for i = 2, n - 1 do
  -- for i = 1, n do
    B1:get(i, p)
    local d = a * p[1] + b * p[2] + c
    if d_min > d then
      d_min = d
    end
    if d_max < d then
      d_max = d
    end
  end

  if not B1:is_rational() then
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

  print(("X= %.17g\t%.17g\t%.17g\t| %.17g %.17g"):format(a, b, c, d_min, d_max))

  return a, b, c, d_min, d_max
end

local function clip_both(H, d_min, d_max)
  local t1 = 1
  local t2 = 0

  local n = #H
  local p = H[n]
  local pt = p[1]
  local pd = p[2]

  print(("pd %.17g"):format(pd))

  for i = 1, n do
    local q = H[i]
    local qt = q[1]
    local qd = q[2]

    print(("qd %.17g / %.17g [%d]"):format(qd, pd - qd, i))

    -- if d_min - 1e-11 <= pd and pd <= d_max + 1e-11 then
    if d_min <= pd and pd <= d_max then
      if t1 > pt then
        t1 = pt
      end
      if t2 < pt then
        t2 = pt
      end
    end

    local d = pd - qd
    if d ~= 0 then
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

local function clip(B1, B2)
  local a, b, c, d_min, d_max = fat_line(B2, B1)

  local n = B1:size()
  local m = n - 1
  local H = {}

  if B1:is_rational() then
    local c1 = c + d_min
    local c2 = c - d_max
    local P1 = {}
    local P2 = {}
    local p = point3()
    for i = 1, n do
      B1:get(i, p)
      local t = (i - 1) / m
      local u = a * p[1] + b * p[2]
      local w = p[3]
      P1[i] = point2(t, u + w * c1)
      P2[i] = point2(t, u + w * c2)
    end
    quickhull(P1, H)
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
      B1:get(i, p)
      P[i] = point2((i - 1) / m, a * p[1] + b * p[2] + c)
    end
    quickhull(P, H)
    return clip_both(H, d_min, d_max)
  end
end

local function print_bezier(b)
  for i = 1, b:size() do
    print("B", i, tostring(b:get(i, point2())))
  end
end

local function iterate(b1, b2, u1, u2, u3, u4, m, result)
  local U1 = result[1]
  local n = #U1
  if n > m then
    return result
  end

  print(u1, u2, u3, u4)

  local B1 = bezier(b1):clip(u1, u2)
  -- print_bezier(B1)
  local B2 = bezier(b2):clip(u3, u4)
  -- print_bezier(B2)

  local t1, t2 = clip(B1, B2)
  if not t1 then
    print "NOT CLIPPED (1)"
    return result
  end
  local a = u2 - u1
  u2 = u1 + a * t2
  u1 = u1 + a * t1

  local t3, t4 = clip(B2, B1)
  if not t3 then
    print "NOT CLIPPED (2)"
    return result
  end
  local b = u4 - u3
  u4 = u3 + b * t4
  u3 = u3 + b * t3

  if u2 - u1 <= epsilon and u4 - u3 <= epsilon then
    local t1 = (u1 + u2) / 2
    local t2 = (u3 + u4) / 2
    local U2 = result[2]

    for i = 1, n do
      local a = U1[i] - t1
      if a < 0 then
        a = -a
      end
      if a <= epsilon then
        local b = U2[i] - t2
        if b < 0 then
          b = -b
        end
        if b <= epsilon then
          return result
        end
      end
    end

    n = n + 1
    U1[n] = t1
    U2[n] = t2
    print("DONE", t1, t2)
    return result
  end

  local d_epsilon = 1e-16
  local d_epsilon = 2.22044604925031e-16 / 2
  u1 = u1 - d_epsilon if u1 < 0 then u1 = 0 end
  u2 = u2 + d_epsilon if u2 > 1 then u2 = 1 end
  u3 = u3 - d_epsilon if u3 < 0 then u3 = 0 end
  u4 = u4 + d_epsilon if u4 > 1 then u4 = 1 end

  if t2 - t1 > 0.8 or t4 - t3 > 0.8 then
    if a < b then
      print "SPLIT (1)"
      local u5 = (u3 + u4) / 2
      iterate(b1, b2, u1, u2, u3, u5, m, result)
      return iterate(b1, b2, u1, u2, u5, u4, m, result)
    else
      print "SPLIT (2)"
      local u5 = (u1 + u2) / 2
      iterate(b1, b2, u1, u5, u3, u4, m, result)
      return iterate(b1, b2, u5, u2, u3, u4, m, result)
    end
  else
    return iterate(b1, b2, u1, u2, u3, u4, m, result)
  end
end

return function (b1, b2, result)
  local U1 = result[1]
  local U2 = result[2]
  local n = #U1
  for i = 1, n do
    U1[i] = nil
    U2[i] = nil
  end
  result.is_identical = nil

  local m = (b1:size() - 1) * (b2:size() - 1)
  iterate(b1, b2, 0, 1, 0, 1, m, result)

  local n = #U1
  if n > m then
    print("IS_IDENTICAL", n, m)

    local t_min = U1[1]
    local t_max = t_min
    local u_min = U2[1]
    local u_max = u_min

    U1[1] = nil
    U2[1] = nil

    for i = 2, n do
      local t = U1[i]
      local u = U2[i]

      U1[i] = nil
      U2[i] = nil

      if t_min > t then
        t_min = t
        u_min = u
      end
      if t_max < t then
        t_max = t
        u_max = u
      end
    end

    local b3 = bezier(b1):reverse()
    local b4 = bezier(b2):reverse()
    iterate(b3, b4, 0, 1, 0, 1, 1, result)

    for i = 1, #U1 do
      local t = 1 - U1[i]
      local u = 1 - U2[i]

      U1[i] = nil
      U2[i] = nil

      if t_min > t then
        t_min = t
        u_min = u
      end
      if t_max < t then
        t_max = t
        u_max = u
      end
    end

    U1[1] = t_min
    U1[2] = t_max
    U2[1] = u_min
    U2[2] = u_max
    result.is_identical = true

    return result
  else
    return result
  end
end
