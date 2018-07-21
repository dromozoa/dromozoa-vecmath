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

local class = { is_bernstein = true }
local metatable = { __index = class }

local setmetatable = setmetatable
local type = type

local function eval(n, a, b, c)
  if n < 3 then
    if n == 0 then
      return 0
    elseif n == 1 then
      return a[1]
    elseif n == 2 then
      return (1 - b) * a[1] + b * a[2]
    end
  else
    local v = a[1]
    local t = b * v
    local u = v - t
    c[1] = u

    for i = 2, n - 1 do
      local v = a[i]
      local t = b * v
      local u = v - t
      c[i - 1] = c[i - 1] + t
      c[i] = u
    end

    local v = a[n]
    local t = b * v
    local u = v - t
    c[n - 1] = c[n - 1] + t

    return eval(n - 1, c, b, c)
  end
end

-- a:set(bernstein b)
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
  local n = #a
  if n < 3 then
    return eval(n, a, b)
  else
    return eval(n, a, b, {})
  end
end

-- class(number b, ...)
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
