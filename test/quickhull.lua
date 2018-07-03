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
local quickhull = require "dromozoa.vecmath.quickhull"

local unpack = table.unpack or unpack

local _ = element
local point2 = vecmath.point2
local vector2 = vecmath.vector2
local curve = vecmath.curve

local P = {}

-- circle
if false then
  local m = 4
  local n = 30
  for i = 1, m do
    local t = i / m * 300
    for j = 1, n do
      local u = j / n * math.pi * 2
      P[#P + 1] = point2(math.cos(u) * t, math.sin(u) * t)
    end
  end
end

-- square
if false then
  local n = 30
  for i = -n, n do
    for j = -n, n do
      if math.abs(i) ~= math.abs(j) then
        P[#P + 1] = point2(i * 10, j * 10)
      end
    end
  end
end

-- square2
if true then
  local n = 28
  for i = -n, n do
    local m = n - math.abs(i)
    m = math.floor((m + 2) / 4) * 4
    for j = -m, m do
      P[#P + 1] = point2(i * 10, j * 10)
    end
  end
end

local root = _"g" {
  transform = "translate(320, 320)";
}

local R = quickhull(P, {})

for i = 1, #P do
  local p = P[i]
  root[#root + 1] = _"circle" {
    cx = p.x;
    cy = p.y;
    r = 2;
    fill = "#333";
  }
end

local p = R[1]
local d = path_data():M(p.x, p.y)
for i = 2, #R do
  local p = R[i]
  d:L(p.x, p.y)
end
d:Z()

root[#root + 1] = _"path" {
  d = d;
  fill = "none";
  stroke = "#33F";
}

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
