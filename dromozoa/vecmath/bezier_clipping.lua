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
local p_epsilon = 1e-10
local t_epsilon = 1e-10
local d_epsilon = 1e-9

local function fat_line(B)
  local p = point2()
  local q = point2()
  local v = vector2()

  local n = B:size()
  B:get(1, p)
  B:get(n, q)
  v:sub(q, p)
  local distance = v:length()
  print(distance)
  assert(distance > 0)
  v:normalize()

  local x = v[1]
  local a = v[2]
  local b = -x
  local c = x * p[2] - a * p[1]

  local d_min = 0
  local d_max = 0
  for i = 2, n - 1 do
    B:get(i, p)
    local d = a * p[1] + b * p[2] + c
    if d_min > d then
      d_min = d
    end
    if d_max < d then
      d_max = d
    end
  end

  if not B:is_rational() then
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

  d_min = d_min - distance * d_epsilon
  d_max = d_max + distance * d_epsilon

  return a, b, c, d_min, d_max
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
  local a, b, c, d_min, d_max = fat_line(B2)

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

local function iterate(B1, B2, u1, u2, u3, u4, m, result)
  assert(0 <= u1 and u1 <= 1)
  assert(0 <= u2 and u2 <= 1)
  assert(u1 <= u2)
  assert(0 <= u3 and u3 <= 1)
  assert(0 <= u4 and u4 <= 1)
  assert(u3 <= u4)

  local U1 = result[1]
  local n = #U1
  if n > m then
    return result
  end

  local done = false

  local p1 = B1:get(1, point2())
  local p2 = B1:get(B1:size(), point2())
  local p3 = B2:get(1, point2())
  local p4 = B2:get(B2:size(), point2())
  if p1:epsilon_equals(p2, p_epsilon) or p3:epsilon_equals(p4, p_epsilon) then
    done = true
  end

  -- if u2 - u1 <= t_epsilon and u4 - u3 <= t_epsilon then
  --   done = true
  -- end

  if done then
    local U2 = result[2]
    local t1 = (u1 + u2) / 2
    local t2 = (u3 + u4) / 2

    for i = 1, n do
      local a = U1[i] - t1
      if a < 0 then
        a = -a
      end
      if a <= t_epsilon then
        local b = U2[i] - t2
        if b < 0 then
          b = -b
        end
        if b <= t_epsilon then
          return result
        end
      end
    end

    n = n + 1
    U1[n] = t1
    U2[n] = t2
    print("done", t1, t2)
    return result
  end

  local t1, t2 = clip(B1, B2)
  if not t1 then
    print "empty clipped (1)"
    return result
  end
  assert(0 <= t1 and t1 <= 1)
  assert(0 <= t2 and t2 <= 1)
  assert(t1 <= t2)
  local a = u2 - u1
  u2 = u1 + a * t2
  u1 = u1 + a * t1
  B1:clip(t1, t2)

  local p1 = B1:get(1, point2())
  local p2 = B1:get(B1:size(), point2())
  local p3 = B2:get(1, point2())
  local p4 = B2:get(B2:size(), point2())
  if p1:epsilon_equals(p2, p_epsilon) or p3:epsilon_equals(p4, p_epsilon) then
    done = true
  end

  -- if u2 - u1 <= t_epsilon and u4 - u3 <= t_epsilon then
  --   done = true
  -- end

  if done then
    local U2 = result[2]
    local t1 = (u1 + u2) / 2
    local t2 = (u3 + u4) / 2

    for i = 1, n do
      local a = U1[i] - t1
      if a < 0 then
        a = -a
      end
      if a <= t_epsilon then
        local b = U2[i] - t2
        if b < 0 then
          b = -b
        end
        if b <= t_epsilon then
          return result
        end
      end
    end

    n = n + 1
    U1[n] = t1
    U2[n] = t2
    print("done", t1, t2)
    return result
  end

  local t3, t4 = clip(B2, B1)
  if not t3 then
    print "empty clipped (2)"
    return result
  end
  assert(0 <= t3 and t3 <= 1)
  assert(0 <= t4 and t4 <= 1)
  assert(t3 <= t4)
  local b = u4 - u3
  u4 = u3 + b * t4
  u3 = u3 + b * t3
  B2:clip(t3, t4)

  if t2 - t1 > 0.8 or t4 - t3 > 0.8 then
    if a < b then
      print "split (1)"
      local B5 = bezier(B1)
      local B6 = bezier(B2):clip(0.5, 1)
      B2:clip(0, 0.5)
      local u5 = (u3 + u4) / 2
      assert(u3 <= u5 and u5 <= u4)
      iterate(B1, B2, u1, u2, u3, u5, m, result)
      return iterate(B5, B6, u1, u2, u5, u4, m, result)
    else
      print "split (2)"
      local B5 = bezier(B1):clip(0.5, 1)
      local B6 = bezier(B2)
      B1:clip(0, 0.5)
      local u5 = (u1 + u2) / 2
      assert(u1 <= u5 and u5 <= u2)
      iterate(B1, B2, u1, u5, u3, u4, m, result)
      return iterate(B5, B6, u5, u2, u3, u4, m, result)
    end
  else
    return iterate(B1, B2, u1, u2, u3, u4, m, result)
  end
end

return function (b1, b2, result)
  local B1 = bezier(b1)
  local B2 = bezier(b2)

  local U1 = result[1]
  local U2 = result[2]
  local n = #U1
  for i = 1, n do
    U1[i] = nil
    U2[i] = nil
  end
  result.is_identical = nil

  local m = (B1:size() - 1) * (B2:size() - 1)
  iterate(B1, B2, 0, 1, 0, 1, m, result)

  local n = #U1
  if n > m then
    print "IS_IDENTICAL"

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

    local B1 = bezier(b1):reverse()
    local B2 = bezier(b2):reverse()
    iterate(B1, B2, 0, 1, 0, 1, 1, result)

    assert(#U1 == 2)
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
