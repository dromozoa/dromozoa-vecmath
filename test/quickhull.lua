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

local element = require "dromozoa.dom.element"
local space_separated = require "dromozoa.dom.space_separated"
local xml_document = require "dromozoa.dom.xml_document"
local path_data = require "dromozoa.svg.path_data"
local vecmath = require "dromozoa.vecmath"

local unpack = table.unpack or unpack

local _ = element
local point2 = vecmath.point2
local vector2 = vecmath.vector2
local curve = vecmath.curve

local m = 4
local n = 30

local P = {}
for i = 1, m do
  local t = i / m * 300
  for j = 1, n do
    local u = j / n * math.pi * 2
    P[#P + 1] = point2(math.cos(u) * t, math.sin(u) * t)
  end
end

local root = _"g" {
  transform = "translate(320, 320)";
}

for i = 1, #P do
  local p = P[i]
  root[#root + 1] = _"circle" {
    cx = p.x;
    cy = p.y;
    r = 2;
    fill = "#999";
  }
end

local min = 1
local min_x = P[1].x
local max = 1
local max_x = min_x

for i = 2, #P do
  local p = P[i]
  local x = p.x
  if min_x > x then
    min = i
    min_x = x
  end
  if max_x < x then
    max = i
    max_x = x
  end
end

root[#root + 1] = _"line" {
  x1 = P[min].x;
  y1 = P[min].y;
  x2 = P[max].x;
  y2 = P[max].y;
  fill = "none";
  stroke = "#333";
}

local list = {
  n = 0;
  after = {};
}

for i = 1, #P do
  local p = P[i]
  if i ~= min and i ~= max then
    local prev_id = list.last
    if prev_id then
      list.after[prev_id] = i
    else
      list.first = i
    end
    list.last = i
  end
end

local id = list.first
while id do
  local p = P[id]
  root[#root + 1] = _"circle" {
    cx = p.x;
    cy = p.y;
    r = 2;
    fill = "#66F";
  }
  id = list.after[id]
end

local id = list.first
while id do
  local p = P[id]
  root[#root + 1] = _"circle" {
    cx = p.x;
    cy = p.y;
    r = 2;
    fill = "#66F";
  }
  id = list.after[id]
end

local pos
local pos_d
local neg
local neg_d

local v1 = vector2():sub(P[max], P[min])
local v2 = vector2()

local id = list.first
while id do
  local p = P[id]
  local d = v1:cross(v2:sub(p, P[min]))
  if d > 0 then
    if not pos_d or pos_d < d then
      pos = id
      pos_d = d
    end
  else
    if not neg_d or neg_d > d then
      neg = id
      neg_d = d
    end
  end
  id = list.after[id]
end

root[#root + 1] = _"circle" {
  cx = P[pos].x;
  cy = P[pos].y;
  r = 2;
  fill = "#F66";
}

root[#root + 1] = _"circle" {
  cx = P[neg].x;
  cy = P[neg].y;
  r = 2;
  fill = "#F66";
}

local d = path_data()
d:M(P[min].x, P[min].y)
d:L(P[neg].x, P[neg].y)
d:L(P[max].x, P[max].y)
d:L(P[pos].x, P[pos].y)
d:Z()

root[#root + 1] = _"path" {
  d = d;
  fill = "none";
  stroke = "#333";
}

local id = list.first
while id do
  local p = P[id]
  local d = v1:cross(v2:sub(p, P[min]))
  if d > 0 then
    if not pos_d or pos_d < d then
      pos = id
      pos_d = d
    end
  else
    if not neg_d or neg_d > d then
      neg = id
      neg_d = d
    end
  end
  id = list.after[id]
end

local p1 = P[min]
local p2 = P[max]
local p3 = P[pos]

local u1 = vector2():sub(p2, p1)
local u2 = vector2():sub(p3, p2)
local u3 = vector2():sub(p1, p3)
local v1 = vector2()
local v2 = vector2()
local v3 = vector2()

local prev_id
local id = list.first
while id do
  local p = P[id]
  v1:sub(p, p1)
  v2:sub(p, p2)
  v3:sub(p, p3)
  if u1:cross(v1) >= 0 and u2:cross(v2) >= 0 and u3:cross(v3) >= 0 then
    local next_id = list.after[id]
    if prev_id then
      list.after[prev_id] = next_id
    else
      list.first = next_id
    end
    if not next_id then
      list.last = prev_id
    end
    list.after[id] = nil
    id = next_id
  else
    prev_id = id
    id = list.after[id]
  end
end

local id = list.first
while id do
  local p = P[id]
  root[#root + 1] = _"circle" {
    class = "p2";
    cx = p.x;
    cy = p.y;
    r = 2;
    fill = "#6F6";
  }
  id = list.after[id]
end

local svg = _"svg" {
  xmlns = "http://www.w3.org/2000/svg";
  ["xmlns:xlink"] ="http://www.w3.org/1999/xlink";
  version = "1.1";
  width = 640;
  height = 640;
  _"rect" {
    x = 0;
    y = 0;
    width = 640;
    height = 640;
    fill = "none";
    stroke = "#CCC";
  };
  _"path" {
    d = "M640,320 h320";
    fill = "none";
    stroke = "#F00";
  };
  root;
}

local doc = xml_document(svg)
local out = assert(io.open("test.svg", "w"))
doc:serialize(out)
out:write "\n"
out:close()
