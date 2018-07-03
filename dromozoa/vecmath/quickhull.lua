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

local function insert_after(before, after, prev_id, id)
  local next_id = after[prev_id]
  before[next_id] = id
  after[prev_id] = id
  before[id] = prev_id
  after[id] = next_id
end

local function remove(before, after, id)
  local prev_id = before[id]
  local next_id = after[id]
  before[next_id] = prev_id
  after[prev_id] = next_id
  before[id] = nil
  after[id] = nil
  return next_id
end

local function visit(source, before, after, p1i, p2i)
  local p3i = after[p1i]
  if p3i == p2i then
    return
  end

  local i = after[p3i]
  if i == p2i then
    return
  end

  -- p1i, p3i, ..., p2i

  local p1 = source[p1i]
  local p2 = source[p2i]
  local p3 = source[p3i]

  local p1x = p1[1]
  local p1y = p1[2]
  local p2x = p2[1]
  local p2y = p2[2]
  local p3x = p3[1]
  local p3y = p3[2]

  local ux = p3x - p1x
  local uy = p3y - p1y
  local vx = p2x - p3x
  local vy = p2y - p3y

  local p4i
  local p4d
  local p5i
  local p5d

  repeat
    local p = source[i]
    local x = p[1]
    local y = p[2]

    local d2 = ux * (y - p1y) - uy * (x - p1x)
    local d3 = vx * (y - p3y) - vy * (x - p3x)

    if d2 <= 0 and d3 <= 0 then
      i = remove(before, after, i)
    else
      if d2 > 0 then
        if not p4d or p4d < d2 then
          p4i = i
          p4d = d2
          local j = remove(before, after, i)
          insert_after(before, after, p1i, i)
          i = j
        else
          local j = remove(before, after, i)
          insert_after(before, after, p4i, i)
          i = j
        end
      else
        if not p5d or p5d < d3 then
          p5i = i
          p5d = d3
          local j = remove(before, after, i)
          insert_after(before, after, p3i, i)
          i = j
        else
          i = after[i]
        end
      end
    end
  until i == p2i

  visit(source, before, after, p1i, p3i)
  visit(source, before, after, p3i, p2i)
end

return function (source, result)
  local n = #source
  local p1 = source[1]
  local p1i = 1
  local p1x = p1[1]
  local p1y = p1[2]
  local p2i = p1i
  local p2x = p1x
  local p2y = p1y

  for i = 2, n do
    local p = source[i]
    local x = p[1]
    local y = p[2]
    if p1x > x or p1x == x and p1y > y then
      p1i = i
      p1x = x
      p1y = y
    end
    if p2x < x or p2x == x and p2y < y then
      p2i = i
      p2x = x
      p2y = y
    end
  end

  if p1i == p2i then
    result[1] = source[p1i]
    return result
  end

  local vx = p2x - p1x
  local vy = p2y - p1y

  local before = {
    [p1i] = p2i;
    [p2i] = p1i;
  }

  local after = {
    [p1i] = p2i;
    [p2i] = p1i;
  }

  local p3i
  local p3d
  local p4i
  local p4d

  for i = 1, n do
    if i ~= p1i and i ~= p2i then
      local p = source[i]
      local d = vx * (p[2] - p1y) - vy * (p[1] - p1x)
      if d > 0 then
        if not p3d or p3d < d then
          p3i = i
          p3d = d
          insert_after(before, after, p1i, i)
        else
          insert_after(before, after, p3i, i)
        end
      elseif d < 0 then
        if not p4d or p4d > d then
          p4i = i
          p4d = d
          insert_after(before, after, p2i, i)
        else
          insert_after(before, after, p4i, i)
        end
      end
    end
  end

  visit(source, before, after, p1i, p2i)
  visit(source, before, after, p2i, p1i)

  local j = 0
  local i = p1i
  repeat
    j = j + 1
    result[j] = source[i]
    i = after[i]
  until i == p1i

  return result
end
