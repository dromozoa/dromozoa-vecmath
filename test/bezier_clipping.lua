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

local function distance(v1, v2)
  return v1.x * v2.y - v1.y * v2.x
end

local function draw_fat_line(node, P)
  local p1, p2, p3, p4 = unpack(P)
  local v1 = vector2():sub(p4, p1):normalize()
  local v2 = vector2():sub(p2, p1)
  local v3 = vector2():sub(p3, p1)

  local d_min
  local d_max
  local d1 = distance(v1, v2)
  local d2 = distance(v1, v3)
  if d1 * d2 > 0 then
    d_min = math.min(0, d1, d2) * 3 / 4
    d_max = math.max(0, d1, d2) * 3 / 4
  else
    d_min = math.min(0, d1, d2) * 4 / 9
    d_max = math.max(0, d1, d2) * 4 / 9
  end

  print("d_min", d_min)
  print("d_max", d_max)

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

  return d_min, d_max
end

local function draw_cubic_bezier(node, P)
  local p1, p2, p3, p4 = unpack(P)
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

local function draw_convex_full(node, P)
  local p1, p2, p3, p4 = unpack(P)
  node[#node + 1] = _"path" {
    d = path_data():M(p1.x, p1.y):L(p2.x, p2.y):L(p3.x, p3.y):Z();
    fill = "#00F";
    ["fill-opacity"] = 0.125;
  }
  node[#node + 1] = _"path" {
    d = path_data():M(p1.x, p1.y):L(p2.x, p2.y):L(p4.x, p4.y):Z();
    fill = "#00F";
    ["fill-opacity"] = 0.125;
  }
  node[#node + 1] = _"path" {
    d = path_data():M(p1.x, p1.y):L(p3.x, p3.y):L(p4.x, p4.y):Z();
    fill = "#00F";
    ["fill-opacity"] = 0.125;
  }
  node[#node + 1] = _"path" {
    d = path_data():M(p2.x, p2.y):L(p3.x, p3.y):L(p4.x, p4.y):Z();
    fill = "#00F";
    ["fill-opacity"] = 0.125;
  }
end

local function draw_td(node, P, Q, d_min, d_max)
  local p1, p2, p3, p4 = unpack(P)
  local q1, q2, q3, q4 = unpack(Q)

  local v = vector2():sub(p4, p1):normalize()
  local d1 = distance(v, vector2():sub(q1, p1))
  local d2 = distance(v, vector2():sub(q2, p1))
  local d3 = distance(v, vector2():sub(q3, p1))
  local d4 = distance(v, vector2():sub(q4, p1))

  print(d1, d2, d3, d4)

  node[#node + 1] = _"rect" {
    x = 0;
    y = d_min;
    width = 320;
    height = d_max - d_min;
    fill = "#F00";
    ["fill-opacity"] = 0.25;
  }

  local d = path_data()
  d:M(0, d1):L(320/3, d2):L(640/3, d3):L(320, d4)
  node[#node + 1] = _"path" {
    d = d;
    fill = "none";
    stroke = "#999";
  }

  local a1 = point2(0,     d1)
  local a2 = point2(320/3, d2)
  local a3 = point2(640/3, d3)
  local a4 = point2(320,   d4)
  draw_convex_full(node, { a1, a2, a3, a4 })

  local d = path_data()
  d:M(0, d1):C(320/3, d2, 640/3, d3, 320, d4)
  node[#node + 1] = _"path" {
    d = d;
    fill = "none";
    stroke = "#333";
  }

  local d = path_data()
  d:M(0, d1)
  for i = 1, 1024 do
    local t = i / 1024
    local q = curve.cubic_bezier({ q1, q2, q3, q4 }, t, point2())
    d:L(320 * t, distance(v, vector2():sub(q, p1)))
  end
  node[#node + 1] = _"path" {
    d = d;
    fill = "none";
    stroke = "#000";
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
  point2(150, 300);
  point2(150,  150);
}

local root = _"g" {
  transform = "translate(320, 320)";
}

local td_root = _"g" {
  transform = "translate(640, 320)";
}

-- P,Q = Q,P

local d_min, d_max = draw_fat_line(root, P)
draw_cubic_bezier(root, P)
draw_cubic_bezier(root, Q)
draw_convex_full(root, Q)
draw_td(td_root, P, Q, d_min, d_max)

local svg = _"svg" {
  xmlns = "http://www.w3.org/2000/svg";
  ["xmlns:xlink"] ="http://www.w3.org/1999/xlink";
  version = "1.1";
  width = 960;
  height = 640;
  _"rect" {
    x = 0;
    y = 0;
    width = 640;
    height = 640;
    fill = "none";
    stroke = "#CCC";
  };
  _"rect" {
    x = 640;
    y = 0;
    width = 320;
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
  td_root;
}

local doc = xml_document(svg)
local out = assert(io.open("test.svg", "w"))
doc:serialize(out)
out:write "\n"
out:close()
