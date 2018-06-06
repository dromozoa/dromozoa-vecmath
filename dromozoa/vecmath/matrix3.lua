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

local eig3 = require "dromozoa.vecmath.eig3"

local rawset = rawset
local type = type
local cos = math.cos
local sin = math.sin
local sqrt = math.sqrt
local format = string.format

local function to_string(a)
  return format("%.17g, %.17g, %.17g\n%.17g, %.17g, %.17g\n%.17g, %.17g, %.17g\n",
      a[1], a[2], a[3],
      a[4], a[5], a[6],
      a[7], a[8], a[9])
end

local function svd(a, b)
  local a11 = a[1] local a12 = a[2] local a13 = a[3]
  local a21 = a[4] local a22 = a[5] local a23 = a[6]
  local a31 = a[7] local a32 = a[8] local a33 = a[9]

  local x = a11 * a11 + a21 * a21 + a31 * a31
  local y = a12 * a12 + a22 * a22 + a32 * a32
  local z = a13 * a13 + a23 * a23 + a33 * a33
  local s = sqrt((x + y + z) / 3)

  if b then
    local x = sqrt(x)
    local y = sqrt(y)
    local z = sqrt(z)
    b[1] = a11 / x ; b[2] = a12 / y ; b[3] = a13 / z
    b[4] = a21 / x ; b[5] = a22 / y ; b[6] = a23 / z
    b[7] = a31 / x ; b[8] = a32 / y ; b[9] = a33 / z
  end

  return s
end

local function determinant(a)
  local a21 = a[4] local a22 = a[5] local a23 = a[6]
  local a31 = a[7] local a32 = a[8] local a33 = a[9]
  return a[1] * (a22 * a33 - a32 * a23) - a[2] * (a21 * a33 - a31 * a23) + a[3] * (a21 * a32 - a31 * a22)
end

local class = {
  index = {
    1, 2, 3, 4, 5, 6, 7, 8, 9,
    m11 = 1, m12 = 2, m13 = 3,
    m21 = 4, m22 = 5, m23 = 6,
    m31 = 7, m32 = 8, m33 = 9,
  };
  to_string = to_string;
  determinant = determinant;
}
local metatable = { __tostring = to_string }

function class.set_identity(a)
  a[1] = 1 ; a[2] = 0 ; a[3] = 0
  a[4] = 0 ; a[5] = 1 ; a[6] = 0
  a[7] = 0 ; a[8] = 0 ; a[9] = 1
  return a
end

function class.set_scale(a, scale)
  svd(a, a)
  a[1] = a[1] * scale
  a[5] = a[5] * scale
  a[9] = a[9] * scale
  return a
end

function class.get_scale(a)
  return svd(a)
end

function class.add(a, b, c)
  if c then
    if type(b) == "table" then
      a[1] = b[1] + c[1] ; a[2] = b[2] + c[2] ; a[3] = b[3] + c[3]
      a[4] = b[4] + c[4] ; a[5] = b[5] + c[5] ; a[6] = b[6] + c[6]
      a[7] = b[7] + c[7] ; a[8] = b[8] + c[8] ; a[9] = b[9] + c[9]
    else
      a[1] = c[1] + b ; a[2] = c[2] + b ; a[3] = c[3] + b
      a[4] = c[4] + b ; a[5] = c[5] + b ; a[6] = c[6] + b
      a[7] = c[7] + b ; a[8] = c[8] + b ; a[9] = c[9] + b
    end
  else
    if type(b) == "table" then
      a[1] = a[1] + b[1] ; a[2] = a[2] + b[2] ; a[3] = a[3] + b[3]
      a[4] = a[4] + b[4] ; a[5] = a[5] + b[5] ; a[6] = a[6] + b[6]
      a[7] = a[7] + b[7] ; a[8] = a[8] + b[8] ; a[9] = a[9] + b[9]
    else
      a[1] = a[1] + b ; a[2] = a[2] + b ; a[3] = a[3] + b
      a[4] = a[4] + b ; a[5] = a[5] + b ; a[6] = a[6] + b
      a[7] = a[7] + b ; a[8] = a[8] + b ; a[9] = a[9] + b
    end
  end
  return a
end

function class.sub(a, b, c)
  if c then
    a[1] = b[1] - c[1] ; a[2] = b[2] - c[2] ; a[3] = b[3] - c[3]
    a[4] = b[4] - c[4] ; a[5] = b[5] - c[5] ; a[6] = b[6] - c[6]
    a[7] = b[7] - c[7] ; a[8] = b[8] - c[8] ; a[9] = b[9] - c[9]
  else
    a[1] = a[1] - b[1] ; a[2] = a[2] - b[2] ; a[3] = a[3] - b[3]
    a[4] = a[4] - b[4] ; a[5] = a[5] - b[5] ; a[6] = a[6] - b[6]
    a[7] = a[7] - b[7] ; a[8] = a[8] - b[8] ; a[9] = a[9] - b[9]
  end
  return a
end

function class.transpose(a, b)
  if b then
    a[1] = b[1]
    a[2], a[4] = b[4], b[2]
    a[3], a[7] = b[7], b[3]
    a[5] = b[5]
    a[6], a[8] = b[8], b[6]
    a[9] = b[9]
  else
    a[2], a[4] = a[4], a[2]
    a[3], a[7] = a[7], a[3]
    a[6], a[8] = a[8], a[6]
  end
  return a
end

function class.set(a, m11, m12, m13, m21, m22, m23, m31, m32, m33)
  if m12 then
    a[1] = m11 ; a[2] = m12 ; a[3] = m13
    a[4] = m21 ; a[5] = m22 ; a[6] = m23
    a[7] = m31 ; a[8] = m32 ; a[9] = m33
  else
    if type(m11) == "table" then
      a[1] = m11[1] ; a[2] = m11[2] ; a[3] = m11[3]
      a[4] = m11[4] ; a[5] = m11[5] ; a[6] = m11[6]
      a[7] = m11[7] ; a[8] = m11[8] ; a[9] = m11[9]
    else
      a[1] = m11 ; a[2] = 0   ; a[3] = 0
      a[4] = 0   ; a[5] = m11 ; a[6] = 0
      a[7] = 0   ; a[8] = 0   ; a[9] = m11
    end
  end
  return a
end

function class.invert(a, b)
  if b then
    local s = determinant(b)
    if s == 0 then
      return
    end
    local b11 = b[1] local b12 = b[2] local b13 = b[3]
    local b21 = b[4] local b22 = b[5] local b23 = b[6]
    local b31 = b[7] local b32 = b[8] local b33 = b[9]

    a[1] = (b22 * b33 - b23 * b32) / s
    a[2] = (b13 * b32 - b12 * b33) / s
    a[3] = (b12 * b23 - b13 * b22) / s

    a[4] = (b23 * b31 - b21 * b33) / s
    a[5] = (b11 * b33 - b13 * b31) / s
    a[6] = (b13 * b21 - b11 * b23) / s

    a[7] = (b21 * b32 - b22 * b31) / s
    a[8] = (b12 * b31 - b11 * b32) / s
    a[9] = (b11 * b22 - b12 * b21) / s
  else
    local s = determinant(a)
    if s == 0 then
      return
    end
    local a11 = a[1] local a12 = a[2] local a13 = a[3]
    local a21 = a[4] local a22 = a[5] local a23 = a[6]
    local a31 = a[7] local a32 = a[8] local a33 = a[9]

    a[1] = (a22 * a33 - a23 * a32) / s
    a[2] = (a13 * a32 - a12 * a33) / s
    a[3] = (a12 * a23 - a13 * a22) / s

    a[4] = (a23 * a31 - a21 * a33) / s
    a[5] = (a11 * a33 - a13 * a31) / s
    a[6] = (a13 * a21 - a11 * a23) / s

    a[7] = (a21 * a32 - a22 * a31) / s
    a[8] = (a12 * a31 - a11 * a32) / s
    a[9] = (a11 * a22 - a12 * a21) / s
  end
  return a
end

function class.rot_x(a, angle)
  local c = cos(angle)
  local s = sin(angle)
  a[1] = 1 ; a[2] = 0 ; a[3] = 0
  a[4] = 0 ; a[5] = c ; a[6] = -s
  a[7] = 0 ; a[8] = s ; a[9] = c
  return a
end

function class.rot_y(a, angle)
  local c = cos(angle)
  local s = sin(angle)
  a[1] = c  ; a[2] = 0 ; a[3] = s
  a[4] = 0  ; a[5] = 1 ; a[6] = 0
  a[7] = -s ; a[8] = 0 ; a[9] = c
  return a
end

function class.rot_z(a, angle)
  local c = cos(angle)
  local s = sin(angle)
  a[1] = c ; a[2] = -s ; a[3] = 0
  a[4] = s ; a[5] = c  ; a[6] = 0
  a[7] = 0 ; a[8] = 0  ; a[9] = 1
  return a
end

function class.mul(a, b, c)
  if c then
    if type(b) == "table" then
      local b11 = b[1] local b12 = b[2] local b13 = b[3]
      local b21 = b[4] local b22 = b[5] local b23 = b[6]
      local b31 = b[7] local b32 = b[8] local b33 = b[9]

      local c11 = c[1] local c12 = c[2] local c13 = c[3]
      local c21 = c[4] local c22 = c[5] local c23 = c[6]
      local c31 = c[7] local c32 = c[8] local c33 = c[9]

      a[1] = b11 * c11 + b12 * c21 + b13 * c31
      a[2] = b11 * c12 + b12 * c22 + b13 * c32
      a[3] = b11 * c13 + b12 * c23 + b13 * c33

      a[4] = b21 * c11 + b22 * c21 + b23 * c31
      a[5] = b21 * c12 + b22 * c22 + b23 * c32
      a[6] = b21 * c13 + b22 * c23 + b23 * c33

      a[7] = b31 * c11 + b32 * c21 + b33 * c31
      a[8] = b31 * c12 + b32 * c22 + b33 * c32
      a[9] = b31 * c13 + b32 * c23 + b33 * c33
    else
      a[1] = c[1] * b ; a[2] = c[2] * b ; a[3] = c[3] * b
      a[4] = c[4] * b ; a[5] = c[5] * b ; a[6] = c[6] * b
      a[7] = c[7] * b ; a[8] = c[8] * b ; a[9] = c[9] * b
    end
  else
    if type(b) == "table" then
      local a11 = a[1] local a12 = a[2] local a13 = a[3]
      local a21 = a[4] local a22 = a[5] local a23 = a[6]
      local a31 = a[7] local a32 = a[8] local a33 = a[9]

      local b11 = b[1] local b12 = b[2] local b13 = b[3]
      local b21 = b[4] local b22 = b[5] local b23 = b[6]
      local b31 = b[7] local b32 = b[8] local b33 = b[9]

      a[1] = a11 * b11 + a12 * b21 + a13 * b31
      a[2] = a11 * b12 + a12 * b22 + a13 * b32
      a[3] = a11 * b13 + a12 * b23 + a13 * b33

      a[4] = a21 * b11 + a22 * b21 + a23 * b31
      a[5] = a21 * b12 + a22 * b22 + a23 * b32
      a[6] = a21 * b13 + a22 * b23 + a23 * b33

      a[7] = a31 * b11 + a32 * b21 + a33 * b31
      a[8] = a31 * b12 + a32 * b22 + a33 * b32
      a[9] = a31 * b13 + a32 * b23 + a33 * b33
    else
      a[1] = a[1] * b ; a[2] = a[2] * b ; a[3] = a[3] * b
      a[4] = a[4] * b ; a[5] = a[5] * b ; a[6] = a[6] * b
      a[7] = a[7] * b ; a[8] = a[8] * b ; a[9] = a[9] * b
    end
  end
  return a
end

function class.mul_normalize(a, b, c)
  class.mul(a, b, c)
  svd(a, a)
  return a
end

function class.mul_transpose_both(a, b, c)
  class.mul(a, c, b)
  class.transpose(a)
  return a
end

function class.equals(a, b)
  return a and b
      and a[1] == b[1] and a[2] == b[2] and a[3] == b[3]
      and a[4] == b[4] and a[5] == b[5] and a[6] == b[6]
      and a[7] == b[7] and a[8] == b[8] and a[9] == b[9]
end

function class.epsilon_equals(a, b, epsilon)
  if a and b and epsilon then
    local v = a[1] - b[1] if v < 0 then v = -v end if v > epsilon then return false end
    local v = a[2] - b[2] if v < 0 then v = -v end if v > epsilon then return false end
    local v = a[3] - b[3] if v < 0 then v = -v end if v > epsilon then return false end
    local v = a[4] - b[4] if v < 0 then v = -v end if v > epsilon then return false end
    local v = a[5] - b[5] if v < 0 then v = -v end if v > epsilon then return false end
    local v = a[6] - b[6] if v < 0 then v = -v end if v > epsilon then return false end
    local v = a[7] - b[7] if v < 0 then v = -v end if v > epsilon then return false end
    local v = a[8] - b[8] if v < 0 then v = -v end if v > epsilon then return false end
    local v = a[9] - b[9] if v < 0 then v = -v end if v > epsilon then return false end
    return true
  else
    return false
  end
end

function class.set_zero(a)
  a[1] = 0 ; a[2] = 0 ; a[3] = 0
  a[4] = 0 ; a[5] = 0 ; a[6] = 0
  a[7] = 0 ; a[8] = 0 ; a[9] = 0
  return a
end

function class.negate(a, b)
  if b then
    a[1] = -b[1] ; a[2] = -b[2] ; a[3] = -b[3]
    a[4] = -b[4] ; a[5] = -b[5] ; a[6] = -b[6]
    a[7] = -b[7] ; a[8] = -b[8] ; a[9] = -b[9]
  else
    a[1] = -a[1] ; a[2] = -a[2] ; a[3] = -a[3]
    a[4] = -a[4] ; a[5] = -a[5] ; a[6] = -a[6]
    a[7] = -a[7] ; a[8] = -a[8] ; a[9] = -a[9]
  end
  return a
end

function class.transform(a, b, c)
  if c then
    local x = b[1]
    local y = b[2]
    local z = b[3]
    c[1] = a[1] * x + a[2] * y + a[3] * z
    c[2] = a[4] * x + a[5] * y + a[6] * z
    c[3] = a[7] * x + a[8] * y + a[9] * z
  else
    local x = b[1]
    local y = b[2]
    local z = b[3]
    b[1] = a[1] * x + a[2] * y + a[3] * z
    b[2] = a[4] * x + a[5] * y + a[6] * z
    b[3] = a[7] * x + a[8] * y + a[9] * z
  end
  return a
end

function metatable.__index(a, key)
  local value = class[key]
  if value then
    return value
  else
    return a[class.index[key]]
  end
end

function metatable.__newindex(a, key, value)
  rawset(a, class.index[key], value)
end

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(class.set({}, ...), metatable)
  end;
})
