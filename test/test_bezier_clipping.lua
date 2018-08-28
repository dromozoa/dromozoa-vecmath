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
local bezier_clipping = require "dromozoa.vecmath.bezier_clipping"

local point2 = vecmath.point2
local bezier = vecmath.bezier

local _ = element
local n = 64

local function draw_bezier(node, b, stroke)
  local p = b:eval(0, point2())
  local pd = path_data()
  pd:M(p.x, p.y)
  for i = 1, n do
    local t = i / n
    b:eval(t, p)
    pd:L(p.x, p.y)
  end
  node[#node + 1] = _"path" {
    d = pd;
    fill = "none";
    stroke = stroke;
  }
end

local root = _"g" {
  transform = "translate(320,320)";
}

local b1 = vecmath.bezier({-240,0}, {-80,80}, {80,-160}, {240,80})
local b2 = vecmath.bezier({-50,-150}, {-25,200}, {150,300}, {150,150})

local b2 = vecmath.bezier({-50,-150}, {-25,200}, {25,200}, {50,-150})

local b2 = vecmath.bezier({-50,-150}, {-25,400}, {25,-400}, {50,150})

local z = math.cos(math.pi / 4)
local b2 = vecmath.bezier({-200,-200,1}, {200*z,-200*z,z}, {200,200,1})

draw_bezier(root, b1, "#ccc")
draw_bezier(root, b2, "#ccc")

local result = bezier_clipping(bezier(b1), bezier(b2), { {}, {} })

local U = result[1]
for i = 1, #U do
  local p = b1:eval(U[i], point2())
  root[#root + 1] = _"circle" {
    cx = p.x;
    cy = p.y;
    r = 2;
    fill = "#66c";
  }
  print(U[i], tostring(p))
end

local U = result[2]
for i = 1, #U do
  local p = b2:eval(U[i], point2())
  root[#root + 1] = _"circle" {
    cx = p.x;
    cy = p.y;
    r = 2;
    fill = "#c66";
  }
  print(U[i], tostring(p))
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
  root;
}

local doc = xml_document(svg)
local out = assert(io.open("test.svg", "w"))
doc:serialize(out)
out:write "\n"
out:close()
