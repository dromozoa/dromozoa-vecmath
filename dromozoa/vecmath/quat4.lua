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
local setmetatable = setmetatable
local acos = math.acos
local cos = math.cos
local sin = math.sin
local sqrt = math.sqrt

local function set_axis_angle4(a, b)
  local x = b[1]
  local y = b[2]
  local z = b[3]
  local t = b[4] * 0.5
  local u = sin(t) / sqrt(x * x + y * y + z * z)
  a[1] = x * u
  a[2] = y * u
  a[3] = z * u
  a[4] = cos(t)
  return a
end

local function set_matrix3(a, b)
  -- TODO refactor
  local b11 = b[1]
  local b12 = b[2]
  local b13 = b[3]
  local b21 = b[4]
  local b22 = b[5]
  local b23 = b[6]
  local b31 = b[7]
  local b32 = b[8]
  local b33 = b[9]

  local t = b11 + b22 + b33
  if t >= 0 then
    local w = sqrt(t + 1) * 0.5
    local d = w * 4
    a[1] = (b32 - b23) / d
    a[2] = (b13 - b31) / d
    a[3] = (b21 - b12) / d
    a[4] = w
    return a
  else
    if b11 > b22 then
      if b11 > b33 then
        local x = sqrt(b11 - b22 - v33 + 1) * 0.5
        local d = x * 4
        a[1] = x
        a[2] = (b21 + b12) / d
        a[3] = (b13 + b31) / d
        a[4] = (b32 - b23) / d
        return a
      end
    else
      if b22 > b33 then
        local y = sqrt(b22 - b33 - b11 + 1) * 0.5
        local d = y * 4
        a[1] = (b21 + b12) / d
        a[2] = y
        a[3] = (b32 + b23) / d
        a[4] = (b13 - b13) / d
        return a
      end
    end
    local z = sqrt(b33 - b11 - b22 + 1) * 0.5
    local d = z * 4
    a[1] = (b13 + b31) / d
    a[2] = (b32 + b23) / d
    a[3] = z
    a[4] = (b21 - b12) / d
    return a
  end
end

local function interpolate(a, b, c, alpha)
  local bx = b[1]
  local by = b[2]
  local bz = b[3]
  local bw = b[4]
  local d = sqrt(bx * bx + by * by + bz * bz + bw * bw)
  bx = bx / d
  by = by / d
  bz = bz / d
  bw = bw / d

  local cx = c[1]
  local cy = c[2]
  local cz = c[3]
  local cw = c[4]
  local d = sqrt(cx * cx + cy * cy + cz * cz + cw * cw)
  cx = cx / d
  cy = cy / d
  cz = cz / d
  cw = cw / d

  local dot = bx * cx + by * cy + bz * cz + bw * cw
  if dot < 0 then
    local omega = acos(-dot)
    local s = sin(omega)
    local beta = -sin((1 - alpha) * omega) / s
    local alpha = sin(alpha * omega) / s
    a[1] = beta * bx + alpha * cx
    a[2] = beta * by + alpha * cy
    a[3] = beta * bz + alpha * cz
    a[4] = beta * bw + alpha * cw
  else
    local omega = acos(dot)
    local s = sin(omega)
    local beta = sin((1 - alpha) * omega) / s
    local alpha = sin(alpha * omega) / s
    a[1] = beta * bx + alpha * cx
    a[2] = beta * by + alpha * cy
    a[3] = beta * bz + alpha * cz
    a[4] = beta * bw + alpha * cw
  end
  return a
end

local super = tuple4
local class = { is_quat4 = true }
local metatable = { __tostring = super.to_string }

-- a:set(number b, number c, number d, number e)
-- a:set(axis_angle4 b)
-- a:set(tuple4 b)
-- a:set(matrix3 b)
-- a:set(matrix4 b)
-- a:set()
function class.set(a, b, c, d, e)
  if b then
    if c then
      a[1] = b
      a[2] = c
      a[3] = d
      a[4] = e
    else
      local n = #b
      if n == 4 then
        if b.is_axis_angle4 then
          return set_axis_angle4(a, b)
        else
          a[1] = b[1]
          a[2] = b[2]
          a[3] = b[3]
          a[4] = b[4]
        end
      elseif n == 9 then
        return set_matrix3(a, b)
      else
        -- TODO impl set matrix4
      end
    end
  else
    a[1] = 0
    a[2] = 0
    a[3] = 0
    a[4] = 0
  end
  return a
end

-- a:conjugate(quat4 b)
-- a:conjugate()
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

-- a:mul(quat4 b, quat4 c)
-- a:mul(quat4 b)
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

-- a:mul_inverse(quat4 b, quat4 c)
-- a:mul_inverse(quat4 b)
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


-- a:inverse(quat4 b)
-- a:inverse()
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

-- a:normalize(quat4 b)
-- a:normalize()
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

-- a:interpolate(quat4 b, quat4 c, number d)
-- a:interpolate(quat4 b, number c)
function class.interpolate(a, b, c, d)
  if d then
    return interpolate(a, b, c, d)
  else
    return interpolate(a, a, b, c)
  end
end

function metatable.__index(a, key)
  local value = class[key]
  if value then
    return value
  else
    return rawget(a, class.index[key])
  end
end

function metatable.__newindex(a, key, value)
  rawset(a, class.index[key], value)
end

-- class(number b, number c, number d, number e)
-- class(tuple4 b)
-- class()
return setmetatable(class, {
  __index = super;
  __call = function (_, ...)
    return setmetatable(class.set({}, ...), metatable)
  end;
})
