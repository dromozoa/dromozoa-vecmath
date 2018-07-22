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
  if n > 2 then
    local m = n - 1
    local t = (1 - b) * a[1]
    for i = 2, m do
      local u = a[i]
      local v = b * u
      c[i - 1] = t + v
      t = u - v
    end
    c[m] = t + b * a[n]
    return eval(m, c, b, c)
  else
    return (1 - b) * a[1] + b * a[2]
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
  if n > 2 then
    return eval(n, a, b, {})
  elseif n == 2 then
    return (1 - b) * a[1] + b * a[2]
  elseif n == 1 then
    return a[1]
  elseif n == 0 then
    return 0
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
