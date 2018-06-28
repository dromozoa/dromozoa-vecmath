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

function class.linear_bezier(c, t, p)
  return p:interpolate(c[1], c[2], t)
end

function class.diff_linear_bezier(c, t, v)
  return v:sub(c[2], c[1])
end

function class.quadratic_bezier(c, t, p)
  local u = 1 - t
  p:scale    (u * u,     c[1])
  p:scale_add(t * t,     c[3], p)
  p:scale_add(2 * u * t, c[2], p)
  return p
end

function class.diff_quadratic_bezier(c, t, v)
  local u = 1 - t
  p:scale    (  2 * t,     c[3])
  p:scale_add(- 2 * u,     c[1], p)
  p:scale_add(  2 - 4 * t, c[2], p)
  return p
end

function class.cubic_bezier(c, t, p)
  local u = 1 - t
  local _3ut= 3 * u * t
  p:scale    (u * u * u, c[1])
  p:scale_add(t * t * t, c[4], p)
  p:scale_add(u * _3ut,  c[2], p)
  p:scale_add(t * _3ut,  c[3], p)
  return p
end

function class.diff_cubic_bezier(c, t, p)
  local u = 1 - t
  local _t2 = t * t
  local _u2 = u * u
  local _16t = 16 * t
  p:scale    (  4 * t * _t2,           c[5])
  p:scale_add(- 4 * u * _u2,           c[1], p)
  p:scale_add(  _t2 * (12 - _16t),     c[4], p)
  p:scale_add(  _u2 * ( 4 - _16t),     c[2], p)
  p:scale_add(  u * t * (12 - 24 * t), c[3], p)
  return p
end

function class.catmull_rom(c, t, p)
  local u = 1 - t
  local th = t * 0.5
  local uh = u * 0.5
  local tu = t * u
  local tum = -tu
  local tu3_1 = 1 + 3 * tu
  p:scale    (uh * tum,         c[1])
  p:scale_add(uh * (u + tu3_1), c[2], p)
  p:scale_add(th * (t + tu3_1), c[3], p)
  p:scale_add(th * tum,         c[4], p)
  return p
end

function class.catmull_rom_to_cubic_bezier(c, p1, p2)
  local c2 = c[2]
  local c3 = c[3]
  p1:scale_add( 1/6, c3, c2)
  p1:scale_add(-1/6, c[1], p1)
  p2:scale_add(-1/6, c[4], c3)
  p2:scale_add( 1/6, c2, p2)
  return p1, p2
end

return class
