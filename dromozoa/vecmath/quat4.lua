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

local tuple4 = require "dromozoa.vecmath.tuple4"

local rawget = rawget
local rawset = rawset
local sqrt = math.sqrt

local super = tuple4
local class = { is_quat4 = true }
local metatable = { __tostring = super.to_string }

-- TODO set tuple4 (not quat4)

-- quat4 a
-- quat4 a, quat4 b
function class.conjugate(a, b)
  if b then
    a[1] = -b[1]
    a[2] = -b[2]
    a[3] = -b[3]
    a[4] = b[4]
  else
    a[1] = -a[1]
    a[2] = -a[2]
    a[3] = -a[3]
  end
  return a
end

function class.mul(a, b, c)
  if c then
    local bx = b[1]
    local by = b[2]
    local bz = b[3]
    local bw = b[4]
    local cx = c[1]
    local cy = c[2]
    local cz = c[3]
    local cw = c[4]
    a[1] = bw * cx + bx * cw + by * cz - bz * cy
    a[2] = bw * cy - bx * cz + by * cw + bz * cx
    a[3] = bw * cz + bx * cy - by * cx + bz * cw
    a[4] = bw * cw - bx * cx - by * cy - bz * cz
  else
    local ax = a[1]
    local ay = a[2]
    local az = a[3]
    local aw = a[4]
    local bx = b[1]
    local by = b[2]
    local bz = b[3]
    local bw = b[4]
    a[1] = aw * bx + ax * bw + ay * bz - az * by
    a[2] = aw * by - ax * bz + ay * bw + az * bx
    a[3] = aw * bz + ax * by - ay * bx + az * bw
    a[4] = aw * bw - ax * bx - ay * by - az * bz
  end
  return a
end

function class.mul_inverse(a, b, c)
  -- TODO inline
  if c then
    local q = class(c)
    class.inverse(q)
    class.mul(a, b, q)
  else
    local q = class(b)
    class.inverse(q)
    class.mul(a, q)
  end
  return a
end

function class.inverse(a, b)
  if b then
    local x = b[1]
    local y = b[2]
    local z = b[3]
    local w = b[4]
    local d = x * x + y * y + z * z + w * w
    a[1] = -x / d
    a[2] = -y / d
    a[3] = -z / d
    a[4] = w / d
  else
    local x = a[1]
    local y = a[2]
    local z = a[3]
    local w = a[4]
    local d = x * x + y * y + z * z + w * w
    a[1] = -x / d
    a[2] = -y / d
    a[3] = -z / d
    a[4] = w / d
  end
  return a
end

function class.normalize(a, b)
  if b then
    local x = b[1]
    local y = b[2]
    local z = b[3]
    local w = b[4]
    local d = sqrt(x * x + y * y + z * z + w * w)
    a[1] = x / d
    a[2] = y / d
    a[3] = z / d
    a[4] = w / d
  else
    local x = a[1]
    local y = a[2]
    local z = a[3]
    local w = a[4]
    local d = sqrt(x * x + y * y + z * z + w * w)
    a[1] = x / d
    a[2] = y / d
    a[3] = z / d
    a[4] = w / d
  end
  return a
end

function class.interpolate(a, b, c, d)
  if d then
    class.normalize(a, b)
    b = c
    c = d
  else
    class.normalize(a)
  end

  local ax = a[1]
  local ay = a[2]
  local az = a[3]
  local aw = a[4]
  local bx = b[1]
  local by = b[2]
  local bz = b[3]
  local bw = b[4]

  -- normalize b
  local d = sqrt(bx * bx + by * by + bz * bz + bw * bw)
  bx = bx / d
  by = by / d
  bz = bz / d
  bw = bw / d

  -- dot = cos
  local t = ax * bx + ay * by + az * bz + aw * bw

  -- same quat
  if math.abs(t) <= 1 then
    return
  end

  -- angle
  local t = math.acos(t)

  local u = math.sin(c)
  local s = math.sin((1 - c) * t) / u
  local t = math.sin(c * t) / u

  a[1] = s * ax + t * bx
  a[2] = s * ay + t * by
  a[3] = s * az + t * bz
  a[4] = s * aw + t * bw

  return a
end

function metatable.__index(a, key)
  local value = class[key]
  if value then
    return value
  else
    return rawget(a, super.index[key])
  end
end

function metatable.__newindex(a, key, value)
  rawset(a, super.index[key], value)
end

return setmetatable(class, {
  __index = super;
  __call = function (_, ...)
    return setmetatable(class.set({}, ...), metatable)
  end;
})
