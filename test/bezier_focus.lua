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

local point2 = vecmath.point2
local vector2 = vecmath.vector2
local matrix2 = vecmath.matrix2
local bezier = vecmath.bezier
local polynomial = vecmath.polynomial

local verbose = os.getenv "VERBOSE" == "1"

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

local root = _"g" {}

local y = 0

local function draw(B)
  local node = _"g" {
    transform = "translate(320,320)";
  }

  root[#root + 1] = _"g" {
    transform = "translate(0," .. y .. ")";
    _"rect" {
      x = 0;
      y = 0;
      width = 640;
      height = 640;
      fill = "none";
      stroke = "#CCC";
    };
    node;
  }
  y = y + 640

  draw_bezier(node, B, "#666")

  local F1 = bezier(B):focus()
  local F2 = bezier({1,1,1},{1,1,1},{1,1,1},{1,1,1},{1,1,1},{1,1,1},{1,1,1},{1,1,1}):focus(B)
  if F1 then
    draw_bezier(node, F1, "#F33")
    assert(F2)
    assert(#F1[1] == #F2[1])
    assert(#F1[2] == #F2[2])
    assert(#F1[3] == #F2[3])
    draw_bezier(node, F2, "#33F")
  end
end

draw(bezier({-120,0}, {-40,40}, {40,-80}, {120,40}))
draw(bezier({145,-15}, {147.5,20}, {165,30}, {165,15}))
draw(bezier({-150,-150}, {-25,200}, {25,200}, {150,-150}))
draw(bezier({-50,-150}, {-25,400}, {25,-400}, {50,150}))
local z = math.cos(math.pi / 4)
draw(bezier({-100,-100,1}, {100*z,-100*z,z}, {100,100,1}))
draw(bezier({-200,0},{-50,200},{50,200},{200,0}))
draw(bezier({-200,0},{-190,200},{190,200},{200,0}))

local svg = _"svg" {
  xmlns = "http://www.w3.org/2000/svg";
  ["xmlns:xlink"] ="http://www.w3.org/1999/xlink";
  version = "1.1";
  width = 640;
  height = y;
  root;
}

local doc = xml_document(svg)
local out = assert(io.open("test.svg", "w"))
doc:serialize(out)
out:write "\n"
out:close()
