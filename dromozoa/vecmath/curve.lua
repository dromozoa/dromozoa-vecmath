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
  v:scale    (- 2 * u,     c[1])
  v:scale_add(  2 * t,     c[3], v)
  v:scale_add(  2 - 4 * t, c[2], v)
  return v
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

function class.diff_cubic_bezier(c, t, v)
  local u = 1 - t
  local _9t = 9 * t
  v:scale    (- 3 * u * u,     c[1])
  v:scale_add(  3 * t * t,     c[4], v)
  v:scale_add(  u * (3 - _9t), c[2], v)
  v:scale_add(  t * (6 - _9t), c[3], v)
  return v
end

function class.catmull_rom(c, t, p)
  local u = 1 - t
  local _th = t / 2
  local _uh = u / 2
  local _ut = u * t
  local _mut = -_ut
  local _13ut = 1 + 3 * _ut
  p:scale    (_uh * _mut,        c[1])
  p:scale_add(_uh * (u + _13ut), c[2], p)
  p:scale_add(_th * (t + _13ut), c[3], p)
  p:scale_add(_th * _mut,        c[4], p)
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
