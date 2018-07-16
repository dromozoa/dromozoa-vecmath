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

local class = {}
local metatable = { __index = class }

local setmetatable = setmetatable
local type = type

-- a:set(poly1 b)
function class.set(a, b)
  local n = #b
  for i = 1, n do
    a[i] = b[i]
  end
  for i = n + 1, #a do
    a[i] = nil
  end
  return a
end

-- a:eval(number b)
function class.eval(a, b)
  local v = a[1]
  for i = 2, #a do
    v = v * b + a[i]
  end
  return v
end

-- a:deriv(poly1 b)
-- a:deriv()
function class.deriv(a, b)
  if not b then
    b = a
  end
  local n = #b
  for i = 1, n - 1 do
    a[i] = b[i] * (n - i)
  end
  for i = n, #a do
    a[i] = nil
  end
  return a
end

-- a:integ(poly1 b, number c)
-- a:integ(poly1 b)
-- a:integ(number b)
-- a:integ()
function class.integ(a, b, c)
  if not b then
    b = a
    c = 0
  elseif not c then
    if type(b) == "number" then
      c = b
      b = a
    else
      c = 0
    end
  end
  local n = #b
  local m = n + 1
  for i = 1, n do
    a[i] = b[i] / (m - i)
  end
  a[m] = c
  for i = m + 1, #a do
    a[i] = nil
  end
  return a
end

-- a:add(poly1 b, poly1 c)
-- a:add(poly1 b)
function class.add(a, b, c)
  if not c then
    local m = #a
    local n = #b
    -- a, b, c, d / m=4
    -- n = 6
    -- 0, 0, a, b, c, d
    if m < n then
      for i = n, n - m + 1, -1 do
        a[i] = a[i - (n - m)]
      end
      for i = 1, n - m do
        a[i] = 0
      end
    end
    c = b
    b = a
  end
  local m = #b
  local n = #c
  if m == n then
    for i = 1, m do
      a[i] = b[i] + c[i]
    end
  else
    if m > n then
      m, n = n, m
      b, c = c, b
    end
    -- m < n
    --         b1, b2, b3 / m=3
    -- c1, c2, c3, c4, c5 / n=5
    for i = 1, n - m do
      a[i] = c[i]
    end
    for i = n - m + 1, n do
      a[i] = c[i] + b[i - (n - m)]
    end
  end
  return a
end

-- class(number b, ...)
-- class(poly1 b)
-- class()
return setmetatable(class, {
  __call = function (_, b, ...)
    if b then
      if type(b) == "number" then
        return setmetatable({ b, ... }, metatable)
      else
        return setmetatable(class.set({}, b), metatable)
      end
    else
      return setmetatable({}, metatable)
    end
  end;
})
