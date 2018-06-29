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

local function in_triangle(p1, p2, p3, q)
  local p1_x = p1[1]
  local p1_y = p1[2]
  local p2_x = p2[1]
  local p2_y = p2[2]
  local p3_x = p3[1]
  local p3_y = p3[2]
  local q_x = q[1]
  local q_y = q[2]
  return (p2_x - p1_x) * (q_y - p1_y) >= (p2_y - p1_y) * (q_x - p1_x)
      and (p3_x - p2_x) * (q_y - p2_y) >= (p3_y - p2_y) * (q_x - p2_x)
      and (p1_x - p3_x) * (q_y - p3_y) >= (p1_y - p3_y) * (q_x - p3_x)
end

return function (source, result)
  local list_first = 1
  local list = {}

  local p1_i = 1
  local p1_x = source[1][1]
  local p2_i = p1_i
  local p2_x = p1_x

  for i = 2, #source do
    list[i - 1] = i
    local x = source[i][1]
    if p1_x > x then
      p1_i = i
      p1_x = x
    end
    if p2_x < x then
      p2_i = i
      p2_x = x
    end
  end

  local p1 = source[p1_i]
  local p1_y = p1[2]
  local p2 = source[p2_i]
  local v_x = p2[1] - p1_x
  local v_y = p2[2] - p1_y

  local p3_i = p1_i
  local p3_d = 0
  local p4_i = p2_i
  local p4_d = 0

  local i = list_first
  while i do
    local p = source[i]
    local d = v_x * (p[2] - p1_y) - v_y * (p[1] - p1_x)
    if d < 0 then
      if p3_d > d then
        p3_i = i
        p3_d = d
      end
    else
      if p4_d < d then
        p4_i = i
        p4_d = d
      end
    end
    i = list[i]
  end

  local p3 = source[p3_i]
  local p4 = source[p4_i]

  local i = list_first
  local prev_i
  while i do
    local p = source[i]
    if in_triangle(p2, p1, p3, p) or in_triangle(p1, p2, p4, p) then
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
  result[1] = p1
  result[2] = p3
  result[3] = p2
  result[4] = p4

  return result
end
