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

local vector2 = require "dromozoa.vecmath.vector2"

return function (source, result)
  local u1 = vector2()
  local u2 = vector2()
  local u3 = vector2()
  local v1 = vector2()
  local v2 = vector2()
  local v3 = vector2()

  local list_first = 1
  local list = {}

  local p0_i = 1
  local p0_x = source[1][1]
  local p1_i = p0_i
  local p1_x = p0_x

  for i = 2, #source do
    list[i - 1] = i
    local x = source[i][1]
    if p0_x > x then
      p0_i = i
      p0_x = x
    end
    if p1_x < x then
      p1_i = i
      p1_x = x
    end
  end

  local p0 = source[p0_i]
  local p1 = source[p1_i]

  local p2_i = p0_i
  local p2_d = 0
  local p3_i = p1_i
  local p3_d = 0

  u1:sub(p1, p0)
  local i = list_first
  while i do
    local d = u1:cross(u2:sub(source[i], p0))
    if d < 0 then
      if p2_d > d then
        p2_i = i
        p2_d = d
      end
    else
      if p3_d < d then
        p3_i = i
        p3_d = d
      end
    end
    i = list[i]
  end

  local p2 = source[p2_i]
  local p3 = source[p3_i]

  u1:sub(p0, p1)
  u2:sub(p2, p0)
  u3:sub(p1, p2)

  local i = list_first
  local prev_i
  while i do
    local p = source[i]
    if u1:cross(v1:sub(p, p1)) >= 0 and u2:cross(v2:sub(p, p0)) >= 0 and u3:cross(v3:sub(p, p2)) >= 0 then
      local next_i = list[i]
      if prev_i then
        list[prev_i] = next_i
      else
        list_first = next_i
      end
      list[i] = nil
      i = next_i
    else
      prev_i = i
      i = list[i]
    end
  end

  -- 0 1 3 0
  u1:sub(p1, p0)
  u2:sub(p3, p1)
  u3:sub(p0, p3)

  local i = list_first
  local prev_i
  while i do
    local p = source[i]
    if u1:cross(v1:sub(p, p0)) >= 0 and u2:cross(v2:sub(p, p1)) >= 0 and u3:cross(v3:sub(p, p3)) >= 0 then
      local next_i = list[i]
      if prev_i then
        list[prev_i] = next_i
      else
        list_first = next_i
      end
      list[i] = nil
      i = next_i
    else
      prev_i = i
      i = list[i]
    end
  end

  -- debug section

  local not_removed = {}

  local i = list_first
  while i do
    not_removed[i] = true
    i = list[i]
  end

  result.not_removed = not_removed
  result[1] = p0
  result[2] = p2
  result[3] = p1
  result[4] = p3

  return result
end
