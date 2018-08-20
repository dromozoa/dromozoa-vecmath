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

local setmetatable = setmetatable
local type = type

-- a:set_polynomial(polynomial b)
local function set_polynomial(a, b)
  local n = #b
  local m = n - 1

  local c = m
  a[1] = b[1]
  for i = 2, n - 2 do
    a[i] = b[i] / c
    c = c * (n - i) / i
  end
  a[m] = b[m] / c
  a[n] = b[n]

  for i = n + 1, #a do
    a[i] = nil
  end

  for i = 2, n do
    local u = a[i - 1]
    for j = i, n do
      local v = a[j]
      a[j] = v + u
      u = v
    end
  end

  return a
end

local class = {
  is_bernstein = true;
  set_polynomial = set_polynomial;
}
local metatable = { __index = class }

-- a:set(polynomial b)
-- a:set(bernstein b)
-- a:set()
function class.set(a, b)
  if b then
    if b.is_polynomial then
      return set_polynomial(a, b)
    else
      local n = #b
      for i = 1, n do
        a[i] = b[i]
      end
      for i = n + 1, #a do
        a[i] = nil
      end
      return a
    end
  else
    for i = 1, #a do
      a[i] = nil
    end
    return a
  end
end

-- a:get(polynomial b)
function class.get(a, b)
  local n = #a
  local m = n -1

  for i = 1, n do
    b[i] = a[i]
  end
  for i = n + 1, #b do
    b[i] = nil
  end

  for i = 2, n do
    local u = b[i - 1]
    for j = i, n do
      local v = b[j]
      b[j] = v - u
      u = v
    end
  end

  local c = m
  for i = 2, n - 2 do
    b[i] = b[i] * c
    c = c * (n - i) / i
  end
  b[m] = b[m] * c

  return b
end

-- a:eval(number b, bernstein c, bernstein d)
-- a:eval(number b, bernstein c)
-- a:eval(number b)
function class.eval(a, b, c, d)
  if d then
    if c then
      class.set(c, a)
      local n = #c
      local m = n + 2
      for i = 2, n do
        d[m - i] = c[n]
        local t = (1 - b) * c[i - 1]
        for j = i, n do
          local u = c[j]
          local v = b * u
          c[j] = t + v
          t = u - v
        end
      end
      local v = c[n]
      d[1] = v
      for i = n + 1, #d do
        d[i] = nil
      end
      return v, c, d
    else
      c = class.set({}, a)
      local n = #c
      local m = n + 2
      for i = 2, n do
        d[m - i] = c[n]
        local t = (1 - b) * c[i - 1]
        for j = i, n do
          local u = c[j]
          local v = b * u
          c[j] = t + v
          t = u - v
        end
      end
      local v = c[n]
      d[1] = v
      for i = n + 1, #d do
        d[i] = nil
      end
      return v, nil, d
    end
  else
    if c then
      class.set(c, a)
    else
      c = class.set({}, a)
    end
    local n = #c
    for i = 2, n do
      local t = (1 - b) * c[i - 1]
      for j = i, n do
        local u = c[j]
        local v = b * u
        c[j] = t + v
        t = u - v
      end
    end
    return c[n], c
  end
end

-- class(number b, ...)
-- class(polynomial b)
-- class(bernstein b)
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
