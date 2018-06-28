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

function class.linear_bezier(p, t, q)
  return q:interpolate(p[1], p[2], t)
end

function class.diff_linear_bezier(p, t, v)
  return v:sub(p[2], p[1])
end

function class.quadratic_bezier(p, t, q)
  local u = 1 - t
  q:scale    (u * u,     p[1])
  q:scale_add(t * t,     p[3], q)
  q:scale_add(2 * u * t, p[2], q)
  return q
end

function class.diff_quadratic_bezier(p, t, v)
  local u = 1 - t
  v:scale    (- 2 * u,     p[1])
  v:scale_add(  2 * t,     p[3], v)
  v:scale_add(  2 - 4 * t, p[2], v)
  return v
end

function class.cubic_bezier(p, t, q)
  local u = 1 - t
  local _3ut = 3 * u * t
  q:scale    (u * u * u, p[1])
  q:scale_add(t * t * t, p[4], q)
  q:scale_add(u * _3ut,  p[2], q)
  q:scale_add(t * _3ut,  p[3], q)
  return q
end

function class.diff_cubic_bezier(p, t, v)
  local u = 1 - t
  local _9t = 9 * t
  v:scale    (- 3 * u * u,     p[1])
  v:scale_add(  3 * t * t,     p[4], v)
  v:scale_add(  u * (3 - _9t), p[2], v)
  v:scale_add(  t * (6 - _9t), p[3], v)
  return v
end

function class.catmull_rom(p, t, q)
  local u = 1 - t
  local _th = t / 2
  local _uh = u / 2
  local _ut = u * t
  local _mut = -_ut
  local _13ut = 1 + 3 * _ut
  q:scale    (_uh * _mut,        p[1])
  q:scale_add(_uh * (u + _13ut), p[2], q)
  q:scale_add(_th * (t + _13ut), p[3], q)
  q:scale_add(_th * _mut,        p[4], q)
  return q
end

function class.catmull_rom_to_cubic_bezier(p, q1, q2)
  local p2 = p[2]
  local p3 = p[3]
  q1:scale_add( 1/6, p3, p2)
  q1:scale_add(-1/6, p[1], q1)
  q2:scale_add( 1/6, p2, p3)
  q2:scale_add(-1/6, p[4], q2)
  return q1, q2
end

return class
