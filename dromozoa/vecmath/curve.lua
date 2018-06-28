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

function class.to_linear_bezier(f, q)
  f(0, q[1])
  f(1, q[2])
  return q
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

function class.to_quadratic_bezier(f, q)
  local q1 = q[1]
  local q2 = q[2]
  local q3 = q[3]

  f(0/2, q1)
  f(1/2, q2)
  f(2/2, q3)

  q2:scale(2)
  q2:scale_add(-1/2, q1, q2)
  q2:scale_add(-1/2, q3, q2)

  return q
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

function class.to_cubic_bezier(f, q)
  local q1 = q[1]
  local q2 = q[2]
  local q3 = q[3]
  local q4 = q[4]

  f(0/3, q1)
  f(1/3, q2)
  f(2/3, q3)
  f(3/3, q4)

  q2:scale(27)
  q2:sub(q4)
  q2:scale_add(-8, q1, q2)

  q3:scale(27)
  q3:sub(q1)
  q3:scale_add(-8, q4, q3)

  local s2 = {}
  q2:get(s2)

  q2:scale    ( 2/18)
  q2:scale_add(-1/18, q3, q2)

  q3:scale    ( 2/18)
  q3:scale_add(-1/18, s2, q3)

  return q
end

function class.quartic_bezier(p, t, q)
  local u = 1 - t
  local _u2 = u * u
  local _t2 = t * t
  local _4ut = 4 * u * t
  q:scale    (_u2 * _u2,     p[1])
  q:scale_add(_t2 * _t2,     p[5], q)
  q:scale_add(_u2 * _4ut,    p[2], q)
  q:scale_add(_t2 * _4ut,    p[4], q)
  q:scale_add(6 * _u2 * _t2, p[3], q)
  return q
end

function class.diff_quartic_bezier(p, t, v)
  local u = 1 - t
  local _u2 = u * u
  local _t2 = t * t
  local _16t = 16 * t
  v:scale    (- 4 * u * _u2,           p[1])
  v:scale_add(  4 * t * _t2,           p[5], v)
  v:scale_add(  _u2 * ( 4 - _16t),     p[2], v)
  v:scale_add(  _t2 * (12 - _16t),     p[4], v)
  v:scale_add(  u * t * (12 - 24 * t), p[3], v)
  return v
end

function class.to_quartic_bezier(f, q)
  local q1 = q[1]
  local q2 = q[2]
  local q3 = q[3]
  local q4 = q[4]
  local q5 = q[5]

  f(0/4, q1)
  f(1/4, q2)
  f(2/4, q3)
  f(3/4, q4)
  f(4/4, q5)

  q2:scale(256)
  q2:sub(q5)
  q2:scale_add(-81, q1, q2)

  q3:scale(16)
  q3:sub(q1)
  q3:sub(q5)

  q4:scale(256)
  q4:sub(q1)
  q4:scale_add(-81, q5, q4)

  local s2 = {}
  local s3 = {}
  q2:get(s2)
  q3:get(s3)

  q2:scale    (   9/576)
  q2:scale_add(-108/576, q3, q2)
  q2:scale_add(   3/576, q4, q2)

  q3:scale    ( 240/576)
  q3:scale_add(-  8/576, q4, q3)
  q3:scale_add(-  8/576, s2, q3)

  q4:scale    (   9/576)
  q4:scale_add(   3/576, s2, q4)
  q4:scale_add(-108/576, s3, q4)

  return q
end

function class.quintic_bezier(p, t, q)
  local u = 1 - t
  local _u2 = u * u
  local _t2 = t * t
  local _u3 = u * _u2
  local _t3 = t * _t2
  local _5ut = 5 * u * t
  local _10u2t2 = 10 * _u2 * _t2
  q:scale    (_u2 * _u3,   p[1])
  q:scale_add(_t2 * _t3,   p[6], q)
  q:scale_add(_u3 * _5ut,  p[2], q)
  q:scale_add(_t3 * _5ut,  p[5], q)
  q:scale_add(u * _10u2t2, p[3], q)
  q:scale_add(t * _10u2t2, p[4], q)
  return q
end

function class.diff_quintic_bezier(p, t, v)
  local u = 1 - t
  local _u2 = u * u
  local _t2 = t * t
  local _25t = 25 * t
  local _50t = 50 * t
  v:scale    (- 5 * _u2 * _u2,         p[1])
  v:scale_add(  5 * _t2 * _t2,         p[6], v)
  v:scale_add(  u * _u2 * ( 5 - _25t), p[2], v)
  v:scale_add(  t * _t2 * (20 - _25t), p[5], v)
  v:scale_add(  t * _u2 * (20 - _50t), p[3], v)
  v:scale_add(  u * _t2 * (30 - _50t), p[4], v)
  return v
end

function class.to_quintic_bezier(f, q)
  local q1 = q[1]
  local q2 = q[2]
  local q3 = q[3]
  local q4 = q[4]
  local q5 = q[5]
  local q6 = q[6]

  f(0/5, q1)
  f(1/5, q2)
  f(2/5, q3)
  f(3/5, q4)
  f(4/5, q5)
  f(5/5, q6)

  q2:scale(3125)
  q2:sub(q6)
  q2:scale_add(-1024, q1, q2)

  q3:scale(3125)
  q3:scale_add(-243, q1, q3)
  q3:scale_add(-32, q6, q3)

  q4:scale(3125)
  q4:scale_add(-32, q1, q4)
  q4:scale_add(-243, q6, q4)

  q5:scale(3125)
  q5:sub(q1)
  q5:scale_add(-1024, q6, q5)

  local s2 = {}
  local s3 = {}
  local s4 = {}
  q2:get(s2)
  q3:get(s3)
  q4:get(s4)

  q2:scale    (  48/30000)
  q2:scale_add(- 48/30000, q3, q2)
  q2:scale_add(  32/30000, q4, q2)
  q2:scale_add(- 12/30000, q5, q2)

  q3:scale    ( 118/30000)
  q3:scale_add(- 92/30000, q4, q3)
  q3:scale_add(  37/30000, q5, q3)
  q3:scale_add(- 58/30000, s2, q3)

  q4:scale    ( 118/30000)
  q4:scale_add(- 58/30000, q5, q4)
  q4:scale_add(  37/30000, s2, q4)
  q4:scale_add(- 92/30000, s3, q4)

  q5:scale    (  48/30000)
  q5:scale_add(- 12/30000, s2, q5)
  q5:scale_add(  32/30000, s3, q5)
  q5:scale_add(- 48/30000, s4, q5)

  return q
end

function class.catmull_rom(p, t, q)
  local u = 1 - t
  local _uh = u / 2
  local _th = t / 2
  local _ut = u * t
  local _mut = -_ut
  local _13ut = 1 + 3 * _ut
  q:scale    (_uh * _mut,        p[1])
  q:scale_add(_uh * (u + _13ut), p[2], q)
  q:scale_add(_th * (t + _13ut), p[3], q)
  q:scale_add(_th * _mut,        p[4], q)
  return q
end

function class.catmull_rom_to_cubic_bezier(p, q)
  local p1 = p[1]
  local p2 = p[2]
  local p3 = p[3]
  local p4 = p[4]
  local q2 = q[2]
  local q3 = q[3]
  q[1]:set(p1)
  q2:scale_add( 1/6, p3, p2)
  q2:scale_add(-1/6, p1, q2)
  q3:scale_add( 1/6, p2, p3)
  q3:scale_add(-1/6, p4, q3)
  q[4]:set(p4)
  return q
end

return class
