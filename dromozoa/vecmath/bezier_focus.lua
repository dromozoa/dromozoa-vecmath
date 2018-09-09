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
local polynomial = require "dromozoa.vecmath.polynomial"
local quickhull = require "dromozoa.vecmath.quickhull"

-- by experimentations
local t_epsilon = 1e-6
local d_epsilon = 1e-11

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
    local X = B[1]
    local Y = B[2]
    local Z = B[3]
    local PX = X:get(polynomial())
    local PY = Y:get(polynomial())
    local PZ = Z:get(polynomial())
    local QX = polynomial(PX):deriv()
    local QY = polynomial(PY):deriv()
    local QZ = polynomial(PZ):deriv()
    local FX = polynomial(p[1])
    local FY = polynomial(p[2])

    FX:mul(PZ)
    FY:mul(PZ)
    FX:sub(PX, FX)
    FY:sub(PY, FY)
    PX:mul(QZ)
    PY:mul(QZ)
    QX:mul(PZ)
    QY:mul(PZ)
    QX:sub(PX)
    QY:sub(PY)
    QX:mul(FX)
    QY:mul(FY)
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
    F = B2
  end

  if F then
    local P = {}
    for i = 1, F:size() do
      local D = explicit_bezier(B1, F:get(i, point2()))
      if D then
        for j = 1, D:size() do
          P[#P + 1] = D:get(j, point2())
        end
      end
    end
    if #P == 0 then
      return
    end
    local H = {}
    quickhull(P, H)
    return clip_both(H, -d_epsilon, d_epsilon)
  end
  return 0, 1
end

local function iterate(b1, b2, u1, u2, u3, u4, m, result)
  local U1 = result[1]
  local n = #U1
  if n > m then
    return result
  end

  local B1 = bezier(b1):clip(u1, u2)
  local B2 = bezier(b2):clip(u3, u4)

  local t1, t2 = focus(B1, B2)
  if not t1 then
    return result
  end
  local a = u2 - u1
  u2 = u1 + a * t2
  u1 = u1 + a * t1

  local t3, t4 = focus(B2, B1)
  if not t3 then
    return result
  end
  local b = u4 - u3
  u4 = u3 + b * t4
  u3 = u3 + b * t3

  if u2 - u1 <= t_epsilon and u4 - u3 <= t_epsilon then
    local t1 = (u1 + u2) / 2
    local t2 = (u3 + u4) / 2
    local U2 = result[2]

    local v1 = bezier(b1):deriv():eval(t1, vector2()):normalize()
    local v2 = bezier(b2):deriv():eval(t2, vector2()):normalize()
    if math.abs(v1:cross(v2)) <= t_epsilon then
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
      return result
    else
      return result
    end
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
  local U1 = result[1]
  local U2 = result[2]
  local n = #U1
  for i = 1, n do
    U1[i] = nil
    U2[i] = nil
  end
  result.is_identical = nil

  local m = (b1:size() - 1) * (b2:size() - 1)
  local m = m * (m - 1) / 2
  iterate(b1, b2, 0, 1, 0, 1, m, result)

  local n = #U1
  if n > m then
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
