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
local xml_document = require "dromozoa.dom.xml_document"
local path_data = require "dromozoa.svg.path_data"
local vecmath = require "dromozoa.vecmath"

local _ = element

local n = 64

local function draw_bezier(node, b)
  local pd = path_data()

  local p = b:eval(0, vecmath.point2())
  pd:M(p.x, p.y)
  for i = 1, n do
    local t = i / n
    b:eval(t, p)
    pd:L(p.x, p.y)
  end

  node[#node + 1] = _"path" {
    d = pd;
    fill = "none";
    stroke = "#333";
  }

  local pd = path_data()

  local p = {}
  for i = 1, #b[1] do
    p[i] = b:get(i, vecmath.point2())
  end
  local q = vecmath.quickhull(p, {})

  -- local p = q[1]
  -- pd:M(p.x, p.y)
  -- for i = 2, #q do
  --   local p = q[i]
  --   pd:L(p.x, p.y)
  -- end

  -- node[#node + 1] = _"path" {
  --   d = pd:Z();
  --   fill = "#ccc";
  --   ["fill-opacity"] = 0.5;
  --   stroke = "none";
  -- }
end

local b1 = vecmath.bezier({-240,0}, {-80,80}, {80,-160}, {240,80})
local b2 = vecmath.bezier({-50,-150}, {-25,200}, {150,300}, {150,150})

local z = math.cos(math.pi / 4)
local b3 = vecmath.bezier({-200,-200,1}, {200*z,-200*z,z}, {200,200,1})

local root = _"g" {
  transform = "translate(320, 320)";
}

local ex_root = _"g" {
  transform = "translate(640, 320)";
}

-- test
-- root[#root + 1] = _"path" {
--   d = path_data()
--     :M(-240,0):C(-80,80,80,-160,240,80)
--     :M(-50,-150):C(-25,200,150,300,150,150)
--     :M(-200,-200):A(400,400,0,0,1,200,200);
--   fill = "none";
--   stroke = "#c33";
-- }

draw_bezier(root, b1)
-- draw_bezier(root, b2)
draw_bezier(root, b3)

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
  ex_root;
}

local doc = xml_document(svg)
local out = assert(io.open("test.svg", "w"))
doc:serialize(out)
out:write "\n"
out:close()
