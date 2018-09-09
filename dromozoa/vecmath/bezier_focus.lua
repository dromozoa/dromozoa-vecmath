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

local bezier = require "dromozoa.vecmath.bezier"
local polynomial = require "dromozoa.vecmath.polynomial"
local quickhull = require "dromozoa.vecmath.quickhull"

local epsilon = 1e-6

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

local function explicit_bezier(B, p)
  local N = bezier()

  if B:is_rational() then
  else
    local X = B[1]
    local Y = B[2]
    local PX = X:get(polynomial())
    local PY = Y:get(polynomial())
    local QX = polynomial(PX):deriv()
    local QY = polynomial(PY):deriv()
    local FX = polynomial(p[1])
    local FY = polynomial(p[2])
    PX:sub(FX)
    PY:sub(FY)
    QX:mul(PX)
    QY:mul(PY)
    QX:add(QY)

    local NX = N[1]
    local NY = N[2]
    NY:set(QX)
    local n = #NY
    local m = n - 1
    for i = 1, n do
      NX[i] = (i - 1) / m
    end
    return N
  end
end

local function focus(B1, B2)
  local F = bezier(B2):focus()
  if not F then
    print "F == B2"
    F = B2
  end

  if F then
    local P = {}
    print("#", F:size())
    for i = 1, F:size() do
      print("-i", i, F:get(i, point2()))
      local D = explicit_bezier(B1, F:get(i, point2()))
      if D then
        for j = 1, D:size() do
          P[#P + 1] = D:get(j, point2())
          print("ij", i, j, P[#P])
        end
      end
    end
    if #P == 0 then
      return nil
    end
    local H = {}
    quickhull(P, H)
    for j = 1, #H do
      print("j", j, tostring(H[j]))
    end
    return clip_both(H, 0, 0)
  end
  return 0, 1
end

local function iterate(b1, b2, u1, u2, u3, u4, m, result)
  local U1 = result[1]
  local n = #U1
  if n > m then
    return result
  end

  print("U", u1, u2, u3, u4)

  local B1 = bezier(b1):clip(u1, u2)
  local B2 = bezier(b2):clip(u3, u4)

  local t1, t2 = focus(B1, B2)
  print("T12", t1, t2)
  if not t1 then
    return result
  end
  local a = u2 - u1
  u2 = u1 + a * t2
  u1 = u1 + a * t1
  -- B1 = bezier(b1):clip(u1, u2)

  local t3, t4 = focus(B2, B1)
  print("T34", t3, t4)
  if not t3 then
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
    return result
  end

  if t2 - t1 > 0.8 and t4 - t3 > 0.8 then
    if a < b then
      local u5 = (u3 + u4) / 2
      iterate(b1, b2, u1, u2, u3, u5, m, result)
      return iterate(b1, b2, u1, u2, u5, u4, m, result)
    else
      local u5 = (u1 + u2) / 2
      iterate(b1, b2, u1, u5, u3, u4, m, result)
      return iterate(b1, b2, u5, u2, u3, u4, m, result)
    end
  else
    return iterate(b1, b2, u1, u2, u3, u4, m, result)
  end
end

return function (b1, b2, result)
  local m = (b1:size() - 1) * (b2:size() - 1)
  local m = m * (m - 1) / 2
  iterate(b1, b2, 0, 1, 0, 1, m, result)
end
