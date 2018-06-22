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

local function draw_fat_line(node, p1, p2, p3, p4)
  local v1 = vector2():sub(p4, p1):normalize()
  local v2 = vector2():sub(p2, p1)
  local v3 = vector2():sub(p3, p1)

  local d_min
  local d_max
  local d1 = v1.x * v2.y - v1.y * v2.x
  local d2 = v1.x * v3.y - v1.y * v3.x
  if d1 * d2 > 0 then
    d_min = math.min(0, d1, d2) * 3 / 4
    d_max = math.max(0, d1, d2) * 3 / 4
  else
    d_min = math.min(0, d1, d2) * 4 / 9
    d_max = math.max(0, d1, d2) * 4 / 9
  end

  local v2 = vector2(-v1.y, v1.x)
  local q1 = point2():scale_add(d_min, v2, p1)
  local q2 = point2():scale_add(d_min, v2, p4)
  local q3 = point2():scale_add(d_max, v2, p4)
  local q4 = point2():scale_add(d_max, v2, p1)
  local d = path_data()
  d:M(q1.x, q1.y):L(q2.x, q2.y):L(q3.x, q3.y):L(q4.x, q4.y):Z()
  node[#node + 1] = _"path" {
    d = d;
    fill = "#f00";
    ["fill-opacity"] = 0.25;
  }

  local d = path_data()
  d:M(p1.x, p1.y):L(p4.x, p4.y)
  node[#node + 1] = _"path" {
    d = d;
    fill = "none";
    stroke = "#F00";
  }
end

local function draw_cubic_bezier(node, p1, p2, p3, p4)
  local d = path_data()
  d:M(p1.x, p1.y):L(p2.x, p2.y):L(p3.x, p3.y):L(p4.x, p4.y)
  node[#node + 1] = _"path" {
    d = d;
    fill = "none";
    stroke = "#999";
  }
  local d = path_data()
  d:M(p1.x, p1.y):C(p2.x, p2.y, p3.x, p3.y, p4.x, p4.y)
  node[#node + 1] = _"path" {
    d = d;
    fill = "none";
    stroke = "#333";
  }
end

local P = {
  point2(-240,    0);
  point2( -80,   80);
  point2(  80, -160);
  point2( 240,   80);
}

local Q = {
  point2(-50, -150);
  point2(-25,  200);
  point2(150, -300);
  point2(150,  150);
}

local root = _"g" {
  transform = "translate(320, 320)";
}

-- P,Q = Q,P

draw_fat_line(root, unpack(P))
draw_cubic_bezier(root, unpack(P))
draw_cubic_bezier(root, unpack(Q))

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
    fill = "#CCC";
  };
  root;
}

local doc = xml_document(svg)
local out = assert(io.open("test.svg", "w"))
doc:serialize(out)
out:write "\n"
out:close()
