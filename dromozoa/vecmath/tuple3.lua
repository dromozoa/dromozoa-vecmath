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

local format = string.format

local class = {
  index = {
    1, 2, 3,
    x = 1,
    y = 2,
    z = 3,
  };
}

function class.set(a, x, y, z)
  if x then
    if y then
      a[1] = x
      a[2] = y
      a[3] = z
    else
      a[1] = x[1]
      a[2] = x[2]
      a[3] = x[3]
    end
  else
    a[1] = 0
    a[2] = 0
    a[3] = 0
  end
  return a
end

function class.get(a, b)
  b[1] = a[1]
  b[2] = a[2]
  b[3] = a[3]
  return a
end

function class.add(a, b, c)
  if c then
    a[1] = b[1] + c[1]
    a[2] = b[2] + c[2]
    a[3] = b[3] + c[3]
  else
    a[1] = a[1] + b[1]
    a[2] = a[2] + b[2]
    a[3] = a[3] + b[3]
  end
  return a
end

function class.sub(a, b, c)
  if c then
    a[1] = b[1] - c[1]
    a[2] = b[2] - c[2]
    a[3] = b[3] - c[3]
  else
    a[1] = a[1] - b[1]
    a[2] = a[2] - b[2]
    a[3] = a[3] - b[3]
  end
  return a
end

function class.negate(a, b)
  if b then
    a[1] = -b[1]
    a[2] = -b[2]
    a[3] = -b[3]
  else
    a[1] = -a[1]
    a[2] = -a[2]
    a[3] = -a[3]
  end
  return a
end

function class.scale(a, s, b)
  if b then
    a[1] = s * b[1]
    a[2] = s * b[2]
    a[3] = s * b[3]
  else
    a[1] = s * a[1]
    a[2] = s * a[2]
    a[3] = s * a[3]
  end
  return a
end

function class.scale_add(a, s, b, c)
  if c then
    a[1] = s * b[1] + c[1]
    a[2] = s * b[2] + c[2]
    a[3] = s * b[3] + c[3]
  else
    a[1] = s * a[1] + b[1]
    a[2] = s * a[2] + b[2]
    a[3] = s * a[3] + b[3]
  end
  return a
end

function class.to_string(a)
  return format("(%.17g, %.17g, %.17g)", a[1], a[2], a[3])
end

function class.equals(a, b)
  return a and b and a[1] == b[1] and a[2] == b[2] and a[3] == b[3]
end

function class.epsilon_equals(a, b, epsilon)
  if a and b and epsilon then
    local v = a[1] - b[1] if v < 0 then v = -v end if v > epsilon then return false end
    local v = a[2] - b[2] if v < 0 then v = -v end if v > epsilon then return false end
    local v = a[3] - b[3] if v < 0 then v = -v end if v > epsilon then return false end
    return true
  else
    return false
  end
end

function class.clamp(a, min, max, b)
  if b then
    local x = b[1]
    local y = b[2]
    local z = b[3]
    if x < min then a[1] = min elseif x > max then a[1] = max else a[1] = x end
    if y < min then a[2] = min elseif y > max then a[2] = max else a[2] = y end
    if z < min then a[3] = min elseif z > max then a[3] = max else a[3] = z end
  else
    local x = a[1]
    local y = a[2]
    local z = a[3]
    if x < min then a[1] = min elseif x > max then a[1] = max end
    if y < min then a[2] = min elseif y > max then a[2] = max end
    if z < min then a[3] = min elseif z > max then a[3] = max end
  end
  return a
end

function class.clamp_min(a, min, b)
  if b then
    local x = b[1]
    local y = b[2]
    local z = b[3]
    if x < min then a[1] = min else a[1] = x end
    if y < min then a[2] = min else a[2] = y end
    if z < min then a[3] = min else a[3] = z end
  else
    if a[1] < min then a[1] = min end
    if a[2] < min then a[2] = min end
    if a[3] < min then a[3] = min end
  end
  return a
end

function class.clamp_max(a, max, b)
  if b then
    local x = b[1]
    local y = b[2]
    local z = b[3]
    if x > max then a[1] = max else a[1] = x end
    if y > max then a[2] = max else a[2] = y end
    if z > max then a[3] = max else a[3] = z end
  else
    if a[1] > max then a[1] = max end
    if a[2] > max then a[2] = max end
    if a[3] > max then a[3] = max end
  end
  return a
end

function class.absolute(a, b)
  if b then
    local x = b[1]
    local y = b[2]
    local z = b[3]
    if x < 0 then a[1] = -x else a[1] = x end
    if y < 0 then a[2] = -y else a[2] = y end
    if z < 0 then a[3] = -z else a[3] = z end
  else
    local x = a[1]
    local y = a[2]
    local z = a[3]
    if x < 0 then a[1] = -x end
    if y < 0 then a[2] = -y end
    if z < 0 then a[3] = -z end
  end
  return a
end

function class.interpolate(a, b, c, d)
  if d then
    local beta = 1 - d
    a[1] = beta * b[1] + d * c[1]
    a[2] = beta * b[2] + d * c[2]
    a[3] = beta * b[3] + d * c[3]
  else
    local beta = 1 - c
    a[1] = beta * a[1] + c * b[1]
    a[2] = beta * a[2] + c * b[2]
    a[3] = beta * a[3] + c * b[3]
  end
  return a
end

return class
