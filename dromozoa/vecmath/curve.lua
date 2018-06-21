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

function class.quadratic_bezier(p1, p2, p3, t, p)
  local u = 1 - t
  return p
      :scale    (u * u,     p1)
      :scale_add(2 * t * u, p2, p)
      :scale_add(t * t,     p3, p)
end

function class.cubic_bezier(p1, p2, p3, p4, t, p)
  local u = 1 - t
  local tu3 = 3 * t * u
  return p
      :scale    (u * u * u, p1)
      :scale_add(u * tu3,   p2, p)
      :scale_add(t * tu3,   p3, p)
      :scale_add(t * t * t, p4, p)
end

function class.catmull_rom(p1, p2, p3, p4, t, p)
  local u = 1 - t
  local th = t * 0.5
  local uh = u * 0.5
  local tu = t * u
  local tum = -tu
  local tu3_1 = 1 + 3 * tu
  return p
      :scale    (uh * tum,         p1)
      :scale_add(uh * (u + tu3_1), p2, p)
      :scale_add(th * (t + tu3_1), p3, p)
      :scale_add(th * tum,         p4, p)
end

function class.catmull_rom_to_cubic_bezier(p1, p2, p3, p4, q1, q2)
  return
      q1:set(p2):scale_add(1/6, p3, q1):scale_add(-1/6, p1, q1),
      q2:set(p3):scale_add(1/6, p2, q2):scale_add(-1/6, p4, q2)
end

return class
