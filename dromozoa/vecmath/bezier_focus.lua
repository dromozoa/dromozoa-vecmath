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

local clip_both = require "dromozoa.vecmath.clip_both"

-- by experimentations
local t_epsilon = 1e-6
local d_epsilon = 1e-11

local function explicit_bezier(B, p)
  local Z = B[3]
  local PX = B[1]:get(polynomial())
  local PY = B[2]:get(polynomial())
  local QX = polynomial(PX):deriv()
  local QY = polynomial(PY):deriv()
  local RX = polynomial(p[1])
  local RY = polynomial(p[2])

  local D = bezier()
  local DX = D[1]
  local DY = D[2]

  if Z[1] then
    local PZ = Z:get(polynomial())
    local QZ = polynomial(PZ):deriv()

    RX:mul(PZ)
    RY:mul(PZ)
    RX:sub(PX, RX)
    RY:sub(PY, RY)
    PX:mul(QZ)
    PY:mul(QZ)
    QX:mul(PZ)
    QY:mul(PZ)
    QX:sub(PX)
    QY:sub(PY)
    QX:mul(RX)
    QY:mul(RY)
    QX:add(QY)

    DY:set(QX)
  else
    PX:sub(RX)
    PY:sub(RY)
    QX:mul(PX)
    QY:mul(PY)
    QX:add(QY)

    DY:set(QX)
  end

  local n = #DY
  local m = n - 1
  for i = 1, n do
    DX[i] = (i - 1) / m
  end
  return D
end

local function focus(B1, B2)
  local F = bezier(B2):focus()
  if not F then
    F = B2
  end
  local P = {}
  for i = 1, F:size() do
    local D = explicit_bezier(B1, F:get(i, point2()))
    for j = 1, D:size() do
      P[#P + 1] = D:get(j, point2())
    end
  end
  if #P ~= 0 then
    local H = {}
    quickhull(P, H)
    return clip_both(H, -d_epsilon, d_epsilon)
  end
end

local function iterate(b1, b2, d1, d2, u1, u2, u3, u4, m, result)
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

    local v1 = d1:eval(t1, vector2()):normalize()
    local v2 = d2:eval(t2, vector2()):normalize()
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
      iterate(b1, b2, d1, d2, u1, u2, u3, u5, m, result)
      return iterate(b1, b2, d1, d2, u1, u2, u5, u4, m, result)
    else
      local u5 = (u1 + u2) / 2
      iterate(b1, b2, d1, d2, u1, u5, u3, u4, m, result)
      return iterate(b1, b2, d1, d2, u5, u2, u3, u4, m, result)
    end
  else
    return iterate(b1, b2, d1, d2, u1, u2, u3, u4, m, result)
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

  local d1 = bezier(b1):deriv()
  local d2 = bezier(b2):deriv()
  local m = (b1:size() - 1) * (b2:size() - 1)
  local m = m * (m - 1) / 2
  iterate(b1, b2, d1, d2, 0, 1, 0, 1, m, result)

  local n = #U1
  if n <= m then
    result.is_identical = nil
    return result
  end

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
  local d3 = bezier(d1):reverse()
  local d4 = bezier(d2):reverse()
  iterate(b3, b4, d3, d4, 0, 1, 0, 1, 1, result)

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
end
