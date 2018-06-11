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

local svd3 = require "dromozoa.vecmath.svd3"

local rawget = rawget
local rawset = rawset
local type = type
local cos = math.cos
local sin = math.sin
local sqrt = math.sqrt
local format = string.format

local function to_string(a)
  return format("%.17g, %.17g, %.17g\n%.17g, %.17g, %.17g\n%.17g, %.17g, %.17g\n", a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9])
end

local function mul(a, b, c)
  if c then
    if type(b) == "table" then
      local b11 = b[1]
      local b12 = b[2]
      local b13 = b[3]
      local b21 = b[4]
      local b22 = b[5]
      local b23 = b[6]
      local b31 = b[7]
      local b32 = b[8]
      local b33 = b[9]

      local c11 = c[1]
      local c12 = c[2]
      local c13 = c[3]
      local c21 = c[4]
      local c22 = c[5]
      local c23 = c[6]
      local c31 = c[7]
      local c32 = c[8]
      local c33 = c[9]

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
      a[1] = c[1] * b
      a[2] = c[2] * b
      a[3] = c[3] * b
      a[4] = c[4] * b
      a[5] = c[5] * b
      a[6] = c[6] * b
      a[7] = c[7] * b
      a[8] = c[8] * b
      a[9] = c[9] * b
    end
  else
    if type(b) == "table" then
      local a11 = a[1]
      local a12 = a[2]
      local a13 = a[3]
      local a21 = a[4]
      local a22 = a[5]
      local a23 = a[6]
      local a31 = a[7]
      local a32 = a[8]
      local a33 = a[9]

      local b11 = b[1]
      local b12 = b[2]
      local b13 = b[3]
      local b21 = b[4]
      local b22 = b[5]
      local b23 = b[6]
      local b31 = b[7]
      local b32 = b[8]
      local b33 = b[9]

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
      a[1] = a[1] * b
      a[2] = a[2] * b
      a[3] = a[3] * b
      a[4] = a[4] * b
      a[5] = a[5] * b
      a[6] = a[6] * b
      a[7] = a[7] * b
      a[8] = a[8] * b
      a[9] = a[9] * b
    end
  end
  return a
end

local function mul_transpose_right(a, b, c)
  local b11 = b[1]
  local b12 = b[2]
  local b13 = b[3]
  local b21 = b[4]
  local b22 = b[5]
  local b23 = b[6]
  local b31 = b[7]
  local b32 = b[8]
  local b33 = b[9]

  local c11 = c[1]
  local c12 = c[4]
  local c13 = c[7]
  local c21 = c[2]
  local c22 = c[5]
  local c23 = c[8]
  local c31 = c[3]
  local c32 = c[6]
  local c33 = c[9]

  a[1] = b11 * c11 + b12 * c21 + b13 * c31
  a[2] = b11 * c12 + b12 * c22 + b13 * c32
  a[3] = b11 * c13 + b12 * c23 + b13 * c33
  a[4] = b21 * c11 + b22 * c21 + b23 * c31
  a[5] = b21 * c12 + b22 * c22 + b23 * c32
  a[6] = b21 * c13 + b22 * c23 + b23 * c33
  a[7] = b31 * c11 + b32 * c21 + b33 * c31
  a[8] = b31 * c12 + b32 * c22 + b33 * c32
  a[9] = b31 * c13 + b32 * c23 + b33 * c33
  return a
end

local function normalize(a, b)
  local m = { a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9] }
  local u = { 1, 0, 0, 0, 1, 0, 0, 0, 1 }
  local v = { 1, 0, 0, 0, 1, 0, 0, 0, 1 }
  svd3(m, u, v)
  mul_transpose_right(b, u, v)
end

local class = {
  index = {
    1, 2, 3, 4, 5, 6, 7, 8, 9,
    m11 = 1, m12 = 2, m13 = 3,
    m21 = 4, m22 = 5, m23 = 6,
    m31 = 7, m32 = 8, m33 = 9,
  };
  to_string = to_string;
  mul = mul;
  mul_transpose_right = mul_transpose_right;
}
local metatable = { __tostring = to_string }

function class.set_identity(a)
  a[1] = 1
  a[2] = 0
  a[3] = 0
  a[4] = 0
  a[5] = 1
  a[6] = 0
  a[7] = 0
  a[8] = 0
  a[9] = 1
  return a
end

function class.set_scale(a, scale)
  normalize(a, a)
  a[1] = a[1] * scale
  a[2] = a[2] * scale
  a[3] = a[3] * scale
  a[4] = a[4] * scale
  a[5] = a[5] * scale
  a[6] = a[6] * scale
  a[7] = a[7] * scale
  a[8] = a[8] * scale
  a[9] = a[9] * scale
  return a
end

function class.get_scale(a)
  local m = { a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9] }
  return svd3(m)
end

function class.add(a, b, c)
  if c then
    if type(b) == "table" then
      a[1] = b[1] + c[1]
      a[2] = b[2] + c[2]
      a[3] = b[3] + c[3]
      a[4] = b[4] + c[4]
      a[5] = b[5] + c[5]
      a[6] = b[6] + c[6]
      a[7] = b[7] + c[7]
      a[8] = b[8] + c[8]
      a[9] = b[9] + c[9]
    else
      a[1] = c[1] + b
      a[2] = c[2] + b
      a[3] = c[3] + b
      a[4] = c[4] + b
      a[5] = c[5] + b
      a[6] = c[6] + b
      a[7] = c[7] + b
      a[8] = c[8] + b
      a[9] = c[9] + b
    end
  else
    if type(b) == "table" then
      a[1] = a[1] + b[1]
      a[2] = a[2] + b[2]
      a[3] = a[3] + b[3]
      a[4] = a[4] + b[4]
      a[5] = a[5] + b[5]
      a[6] = a[6] + b[6]
      a[7] = a[7] + b[7]
      a[8] = a[8] + b[8]
      a[9] = a[9] + b[9]
    else
      a[1] = a[1] + b
      a[2] = a[2] + b
      a[3] = a[3] + b
      a[4] = a[4] + b
      a[5] = a[5] + b
      a[6] = a[6] + b
      a[7] = a[7] + b
      a[8] = a[8] + b
      a[9] = a[9] + b
    end
  end
  return a
end

function class.sub(a, b, c)
  if c then
    a[1] = b[1] - c[1]
    a[2] = b[2] - c[2]
    a[3] = b[3] - c[3]
    a[4] = b[4] - c[4]
    a[5] = b[5] - c[5]
    a[6] = b[6] - c[6]
    a[7] = b[7] - c[7]
    a[8] = b[8] - c[8]
    a[9] = b[9] - c[9]
  else
    a[1] = a[1] - b[1]
    a[2] = a[2] - b[2]
    a[3] = a[3] - b[3]
    a[4] = a[4] - b[4]
    a[5] = a[5] - b[5]
    a[6] = a[6] - b[6]
    a[7] = a[7] - b[7]
    a[8] = a[8] - b[8]
    a[9] = a[9] - b[9]
  end
  return a
end

function class.transpose(a, b)
  if b then
    a[2], a[4] = b[4], b[2]
    a[3], a[7] = b[7], b[3]
    a[6], a[8] = b[8], b[6]
    a[1] = b[1]
    a[5] = b[5]
    a[9] = b[9]
  else
    a[2], a[4] = a[4], a[2]
    a[3], a[7] = a[7], a[3]
    a[6], a[8] = a[8], a[6]
  end
  return a
end

-- TODO support quat4, axis_angle4
function class.set(a, b, m12, m13, m21, m22, m23, m31, m32, m33)
  if b then
    if m12 then
      a[1] = b
      a[2] = m12
      a[3] = m13
      a[4] = m21
      a[5] = m22
      a[6] = m23
      a[7] = m31
      a[8] = m32
      a[9] = m33
    else
      if type(b) == "table" then
        a[1] = b[1]
        a[2] = b[2]
        a[3] = b[3]
        a[4] = b[4]
        a[5] = b[5]
        a[6] = b[6]
        a[7] = b[7]
        a[8] = b[8]
        a[9] = b[9]
      else
        a[1] = b
        a[2] = 0
        a[3] = 0
        a[4] = 0
        a[5] = b
        a[6] = 0
        a[7] = 0
        a[8] = 0
        a[9] = b
      end
    end
  else
    a[1] = 0
    a[2] = 0
    a[3] = 0
    a[4] = 0
    a[5] = 0
    a[6] = 0
    a[7] = 0
    a[8] = 0
    a[9] = 0
  end
  return a
end

function class.invert(a, b)
  if b then
    local b11 = b[1]
    local b12 = b[2]
    local b13 = b[3]
    local b21 = b[4]
    local b22 = b[5]
    local b23 = b[6]
    local b31 = b[7]
    local b32 = b[8]
    local b33 = b[9]
    local u = b22 * b33 - b23 * b32
    local v = b23 * b31 - b21 * b33
    local w = b21 * b32 - b22 * b31
    local d = b11 * u + b12 * v + b13 * w
    a[1] = u / d
    a[2] = (b13 * b32 - b12 * b33) / d
    a[3] = (b12 * b23 - b13 * b22) / d
    a[4] = v / d
    a[5] = (b11 * b33 - b13 * b31) / d
    a[6] = (b13 * b21 - b11 * b23) / d
    a[7] = w / d
    a[8] = (b12 * b31 - b11 * b32) / d
    a[9] = (b11 * b22 - b12 * b21) / d
  else
    local a11 = a[1]
    local a12 = a[2]
    local a13 = a[3]
    local a21 = a[4]
    local a22 = a[5]
    local a23 = a[6]
    local a31 = a[7]
    local a32 = a[8]
    local a33 = a[9]
    local u = a22 * a33 - a23 * a32
    local v = a23 * a31 - a21 * a33
    local w = a21 * a32 - a22 * a31
    local d = a11 * u + a12 * v + a13 * w
    a[1] = u / d
    a[2] = (a13 * a32 - a12 * a33) / d
    a[3] = (a12 * a23 - a13 * a22) / d
    a[4] = v / d
    a[5] = (a11 * a33 - a13 * a31) / d
    a[6] = (a13 * a21 - a11 * a23) / d
    a[7] = w / d
    a[8] = (a12 * a31 - a11 * a32) / d
    a[9] = (a11 * a22 - a12 * a21) / d
  end
  return a
end

function class.determinant(a)
  local a21 = a[4]
  local a22 = a[5]
  local a23 = a[6]
  local a31 = a[7]
  local a32 = a[8]
  local a33 = a[9]
  return a[1] * (a22 * a33 - a32 * a23) - a[2] * (a21 * a33 - a31 * a23) + a[3] * (a21 * a32 - a31 * a22)
end

function class.rot_x(a, angle)
  local c = cos(angle)
  local s = sin(angle)
  a[1] = 1
  a[2] = 0
  a[3] = 0
  a[4] = 0
  a[5] = c
  a[6] = -s
  a[7] = 0
  a[8] = s
  a[9] = c
  return a
end

function class.rot_y(a, angle)
  local c = cos(angle)
  local s = sin(angle)
  a[1] = c
  a[2] = 0
  a[3] = s
  a[4] = 0
  a[5] = 1
  a[6] = 0
  a[7] = -s
  a[8] = 0
  a[9] = c
  return a
end

function class.rot_z(a, angle)
  local c = cos(angle)
  local s = sin(angle)
  a[1] = c
  a[2] = -s
  a[3] = 0
  a[4] = s
  a[5] = c
  a[6] = 0
  a[7] = 0
  a[8] = 0
  a[9] = 1
  return a
end

function class.mul_normalize(a, b, c)
  mul(a, b, c)
  normalize(a, a)
  return a
end

function class.mul_transpose_both(a, b, c)
  local b11 = b[1]
  local b12 = b[4]
  local b13 = b[7]
  local b21 = b[2]
  local b22 = b[5]
  local b23 = b[8]
  local b31 = b[3]
  local b32 = b[6]
  local b33 = b[9]

  local c11 = c[1]
  local c12 = c[4]
  local c13 = c[7]
  local c21 = c[2]
  local c22 = c[5]
  local c23 = c[8]
  local c31 = c[3]
  local c32 = c[6]
  local c33 = c[9]

  a[1] = b11 * c11 + b12 * c21 + b13 * c31
  a[2] = b11 * c12 + b12 * c22 + b13 * c32
  a[3] = b11 * c13 + b12 * c23 + b13 * c33
  a[4] = b21 * c11 + b22 * c21 + b23 * c31
  a[5] = b21 * c12 + b22 * c22 + b23 * c32
  a[6] = b21 * c13 + b22 * c23 + b23 * c33
  a[7] = b31 * c11 + b32 * c21 + b33 * c31
  a[8] = b31 * c12 + b32 * c22 + b33 * c32
  a[9] = b31 * c13 + b32 * c23 + b33 * c33
  return a
end

function class.mul_transpose_left(a, b, c)
  local b11 = b[1]
  local b12 = b[4]
  local b13 = b[7]
  local b21 = b[2]
  local b22 = b[5]
  local b23 = b[8]
  local b31 = b[3]
  local b32 = b[6]
  local b33 = b[9]

  local c11 = c[1]
  local c12 = c[2]
  local c13 = c[3]
  local c21 = c[4]
  local c22 = c[5]
  local c23 = c[6]
  local c31 = c[7]
  local c32 = c[8]
  local c33 = c[9]

  a[1] = b11 * c11 + b12 * c21 + b13 * c31
  a[2] = b11 * c12 + b12 * c22 + b13 * c32
  a[3] = b11 * c13 + b12 * c23 + b13 * c33
  a[4] = b21 * c11 + b22 * c21 + b23 * c31
  a[5] = b21 * c12 + b22 * c22 + b23 * c32
  a[6] = b21 * c13 + b22 * c23 + b23 * c33
  a[7] = b31 * c11 + b32 * c21 + b33 * c31
  a[8] = b31 * c12 + b32 * c22 + b33 * c32
  a[9] = b31 * c13 + b32 * c23 + b33 * c33
  return a
end

function class.equals(a, b)
  return a and b
      and a[1] == b[1]
      and a[2] == b[2]
      and a[3] == b[3]
      and a[4] == b[4]
      and a[5] == b[5]
      and a[6] == b[6]
      and a[7] == b[7]
      and a[8] == b[8]
      and a[9] == b[9]
end

function class.epsilon_equals(a, b, epsilon)
  if a and b then
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
  a[1] = 0
  a[2] = 0
  a[3] = 0
  a[4] = 0
  a[5] = 0
  a[6] = 0
  a[7] = 0
  a[8] = 0
  a[9] = 0
  return a
end

function class.negate(a, b)
  if b then
    a[1] = -b[1]
    a[2] = -b[2]
    a[3] = -b[3]
    a[4] = -b[4]
    a[5] = -b[5]
    a[6] = -b[6]
    a[7] = -b[7]
    a[8] = -b[8]
    a[9] = -b[9]
  else
    a[1] = -a[1]
    a[2] = -a[2]
    a[3] = -a[3]
    a[4] = -a[4]
    a[5] = -a[5]
    a[6] = -a[6]
    a[7] = -a[7]
    a[8] = -a[8]
    a[9] = -a[9]
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

function class.normalize(a, b)
  if b then
    normalize(b, a)
  else
    normalize(a, a)
  end
  return a
end

function class.normalize_cp(a, b)
  if b then
    local b11 = b[1]
    local b12 = b[2]
    local b13 = b[3]
    local b21 = b[4]
    local b22 = b[5]
    local b23 = b[6]
    local b31 = b[7]
    local b32 = b[8]
    local b33 = b[9]

    local d = sqrt(b11 * b11 + b21 * b21 + b31 * b31)
    b11 = b11 / d
    b21 = b21 / d
    b31 = b31 / d

    local d = sqrt(b12 * b12 + b22 * b22 + b32 * b32)
    b12 = b12 / d
    b22 = b22 / d
    b32 = b32 / d

    a[1] = b11
    a[2] = b12
    a[3] = b21 * b32 - b22 * b31
    a[4] = b21
    a[5] = b22
    a[6] = b31 * b12 - b32 * b11
    a[7] = b31
    a[8] = b32
    a[9] = b11 * b22 - b12 * b21
  else
    local a11 = a[1]
    local a12 = a[2]
    local a13 = a[3]
    local a21 = a[4]
    local a22 = a[5]
    local a23 = a[6]
    local a31 = a[7]
    local a32 = a[8]
    local a33 = a[9]

    local d = sqrt(a11 * a11 + a21 * a21 + a31 * a31)
    a11 = a11 / d
    a21 = a21 / d
    a31 = a31 / d

    local d = sqrt(a12 * a12 + a22 * a22 + a32 * a32)
    a12 = a12 / d
    a22 = a22 / d
    a32 = a32 / d

    a[1] = a11
    a[2] = a12
    a[3] = a21 * a32 - a22 * a31
    a[4] = a21
    a[5] = a22
    a[6] = a31 * a12 - a32 * a11
    a[7] = a31
    a[8] = a32
    a[9] = a11 * a22 - a12 * a21
  end
  return a
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

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(class.set({}, ...), metatable)
  end;
})
