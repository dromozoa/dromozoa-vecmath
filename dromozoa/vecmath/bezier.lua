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

local bernstein = require "dromozoa.vecmath.bernstein"
local polynomial = require "dromozoa.vecmath.polynomial"

local setmetatable = setmetatable
local type = type

-- a:get_point2(number b, point2 c)
local function get_point2(a, b, c)
  local z = a[3][b]
  if z then
    c[1] = a[1][b] / z
    c[2] = a[2][b] / z
    return c
  else
    c[1] = a[1][b]
    c[2] = a[2][b]
    return c
  end
end

-- a:get_point3(number b, point3 c)
local function get_point3(a, b, c)
  c[1] = a[1][b]
  c[2] = a[2][b]
  c[3] = a[3][b] or 1
  return c
end

-- a:eval_point2(number b, point2 c)
local function eval_point2(a, b, c)
  local Z = a[3]
  local t = {}
  if Z[1] then
    local z = bernstein.eval(Z, b, t)
    c[1] = bernstein.eval(a[1], b, t) / z
    c[2] = bernstein.eval(a[2], b, t) / z
    return c
  else
    c[1] = bernstein.eval(a[1], b, t)
    c[2] = bernstein.eval(a[2], b, t)
    return c
  end
end

-- a:eval_point3(number b, point3 c)
local function eval_point3(a, b, c)
  local Z = a[3]
  local t = {}
  if Z[1] then
    c[1] = bernstein.eval(a[1], b, t)
    c[2] = bernstein.eval(a[2], b, t)
    c[3] = bernstein.eval(a[3], b, t)
    return c
  else
    c[1] = bernstein.eval(a[1], b, t)
    c[2] = bernstein.eval(a[2], b, t)
    c[3] = 1
    return c
  end
end

local class = {
  is_bezier = true;
  get_point2 = get_point2;
  get_point3 = get_point3;
  eval_point2 = eval_point2;
  eval_point3 = eval_point3;
}
local metatable = { __index = class }

-- a:set(point2 b, point2 c, ...)
-- a:set(point3 b, point3 c, ...)
-- a:set(bezier b)
-- a:set()
function class.set(a, b, c, ...)
  local X = a[1]
  local Y = a[2]
  local Z = a[3]
  if b then
    if c then
      if #b == 2 then
        local points = { b, c, ... }
        local n = #points
        for i = 1, n do
          local p = points[i]
          X[i] = p[1]
          Y[i] = p[2]
        end
        for i = n + 1, #X do
          X[i] = nil
          Y[i] = nil
        end
        bernstein.set(Z)
        return a
      else
        local points = { b, c, ... }
        local n = #points
        for i = 1, n do
          local p = points[i]
          X[i] = p[1]
          Y[i] = p[2]
          Z[i] = p[3]
        end
        for i = n + 1, #X do
          X[i] = nil
          Y[i] = nil
          Z[i] = nil
        end
        return a
      end
    else
      bernstein.set(X, b[1])
      bernstein.set(Y, b[2])
      bernstein.set(Z, b[3])
      return a
    end
  else
    bernstein.set(X)
    bernstein.set(Y)
    bernstein.set(Z)
    return a
  end
end

-- a:set_catmull_rom(point2 p1, point2 p2, point2 p3, point2 p4)
function class.set_catmull_rom(a, p1, p2, p3, p4)
  local X = a[1]
  local Y = a[2]

  local p2x = p2[1]
  local p3x = p3[1]
  local p2y = p2[2]
  local p3y = p3[2]

  X[1] = p2x
  X[2] = p2x + (p3x - p1[1]) / 6
  X[3] = p3x + (p2x - p4[1]) / 6
  X[4] = p3x

  Y[1] = p2y
  Y[2] = p2y + (p3y - p1[2]) / 6
  Y[3] = p3y + (p2y - p4[2]) / 6
  Y[4] = p3y

  for i = 5, #X do
    X[i] = nil
    Y[i] = nil
  end
  bernstein.set(a[3])

  return a
end

-- a:get(number b, point2 c)
-- a:get(number b, point3 c)
function class.get(a, b, c)
  if #c == 2 then
    return get_point2(a, b, c)
  else
    return get_point3(a, b, c)
  end
end

-- a:eval(number b, point2 c)
-- a:eval(number b, point3 c)
function class.eval(a, b, c)
  if #c == 2 then
    return eval_point2(a, b, c)
  else
    return eval_point3(a, b, c)
  end
end

-- a:clip(number min, number max, bezier b)
-- a:clip(number min, number max)
function class.clip(a, min, max, b)
  local t = 0
  if min < 1 then
    t = (max - min) / (1 - min)
  end

  if b then
    local AX = a[1]
    local AY = a[2]
    local AZ = a[3]
    local BX = b[1]
    local BY = b[2]
    local BZ = b[3]

    bernstein.eval(BX, min, nil, AX)
    bernstein.eval(AX, t, AX)
    bernstein.eval(BY, min, nil, AY)
    bernstein.eval(AY, t, AY)
    if BZ[1] then
      bernstein.eval(BZ, min, nil, AZ)
      bernstein.eval(AZ, t, AZ)
    else
      bernstein.set(AZ)
    end

    return a
  else
    local X = a[1]
    local Y = a[2]
    local Z = a[3]

    bernstein.eval(X, min, nil, X)
    bernstein.eval(X, t, X)
    bernstein.eval(Y, min, nil, Y)
    bernstein.eval(Y, t, Y)
    if Z[1] then
      bernstein.eval(Z, min, nil, Z)
      bernstein.eval(Z, t, Z)
    end

    return a
  end
end

-- a:reverse(bezier b)
-- a:reverse()
function class.reverse(a, b)
  if b then
    bernstein.reverse(a[1], b[1])
    bernstein.reverse(a[2], b[2])
    bernstein.reverse(a[3], b[3])
    return a
  else
    bernstein.reverse(a[1])
    bernstein.reverse(a[2])
    bernstein.reverse(a[3])
    return a
  end
end

-- a:deriv(bezier b)
-- a:deriv()
function class.deriv(a, b)
  if b then
    local AX = a[1]
    local AY = a[2]
    local AZ = a[3]
    local BX = b[1]
    local BY = b[2]
    local BZ = b[3]

    if BZ[1] then
    else
      bernstein.deriv(AX, BX)
      bernstein.deriv(AY, BY)
      bernstein.set(AZ)
      return a
    end
  else
    local X = a[1]
    local Y = a[2]
    local Z = a[3]

    if Z[1] then
      local PX = bernstein.get(X, {})
      local PY = bernstein.get(Y, {})
      local PZ = bernstein.get(Z, {})
      local QX = polynomial.deriv({}, PX)
      local QY = polynomial.deriv({}, PY)
      local QZ = polynomial.deriv({}, PZ)
      polynomial.mul(QX, PZ)
      polynomial.mul(PX, QZ)
      polynomial.mul(QY, PZ)
      polynomial.mul(PY, QZ)
      polynomial.sub(QX, PX)
      polynomial.sub(QY, PY)
      polynomial.mul(PZ, PZ)
      bernstein.set_polynomial(X, QX)
      bernstein.elevate(X)
      bernstein.set_polynomial(Y, QY)
      bernstein.elevate(Y)
      bernstein.set_polynomial(Z, PZ)
      return a
    else
      bernstein.deriv(X)
      bernstein.deriv(Y)
      return a
    end
  end
end

-- a:size()
function class.size(a)
  return #a[1]
end

-- a:is_rational()
function class.is_rational(a)
  return a[3][1]
end

-- class(point2 b, point2 c, ...)
-- class(point3 b, point3 c, ...)
-- class(bezier b)
-- class()
return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(class.set({ bernstein(), bernstein(), bernstein() }, ...), metatable)
  end;
})
