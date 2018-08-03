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

local setmetatable = setmetatable
local type = type

local bernstein_eval = bernstein.eval
local bernstein_set = bernstein.set

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
  local X = a[1]
  local Y = a[2]
  local Z = a[3]
  if Z[1] then
    local z = bernstein_eval(Z, b)
    c[1] = bernstein_eval(X, b) / z
    c[2] = bernstein_eval(Y, b) / z
    return c
  else
    c[1] = bernstein_eval(X, b)
    c[2] = bernstein_eval(Y, b)
    return c
  end
end

-- a:eval_point3(number b, point3 c)
local function eval_point3(a, b, c)
  local X = a[1]
  local Y = a[2]
  local Z = a[3]
  if Z[1] then
    c[1] = bernstein_eval(X, b)
    c[2] = bernstein_eval(Y, b)
    c[3] = bernstein_eval(Z, b)
    return c
  else
    c[1] = bernstein_eval(X, b)
    c[2] = bernstein_eval(Y, b)
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
        bernstein_set(Z)
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
      bernstein_set(X, b[1])
      bernstein_set(Y, b[2])
      bernstein_set(Z, b[3])
      return a
    end
  else
    bernstein_set(X)
    bernstein_set(Y)
    bernstein_set(Z)
    return a
  end
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

-- a:eval(number b, point2 c, bezier d, bezier e)
-- a:eval(number b, point3 c, bezier d, bezier e)
-- a:eval(number b, point2 c, bezier d)
-- a:eval(number b, point3 c, bezier d)

-- a:eval(number b, point2 c)
-- a:eval(number b, point3 c)
function class.eval(a, b, c)
  if #c == 2 then
    return eval_point2(a, b, c)
  else
    return eval_point3(a, b, c)
  end
end

-- class(point2 b, point2 c, ...)
-- class(point3 b, point3 c, ...)
-- class(bezier b)
-- class()
return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(class.set({ {}, {}, {} }, ...), metatable)
  end;
})
