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

local verbose = os.getenv "VERBOSE" == "1"
local epsilon = 1e-3

local _ = element
local n = 64

local function draw_bezier(node, b, stroke, stroke_opacity)
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
    ["stroke-opacity"] = stroke_opacity;
  }
end

local function draw_points(node, B, U, fill)
  if verbose then
    print "--"
  end
  for i = 1, #U do
    local p = B:eval(U[i], point2())
    if verbose then
      print(i, U[i], tostring(p))
    end
    node[#node + 1] = _"circle" {
      cx = p.x;
      cy = p.y;
      r = 2;
      fill = fill;
    }
  end
end

local root = _"g" {}

local y = 0

local function check(B1, B2, n)
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

  draw_bezier(node, B1, "#666", 0.5)
  draw_bezier(node, B2, "#666", 0.5)

  if verbose then
    print(("=="):rep(40))
  end

  local result = bezier_clipping(B1, B2, { {}, {} })
  draw_points(node, B1, result[1], "#66C")
  draw_points(node, B2, result[2], "#C66")

  if verbose then
    print("!", #result[1], n)
  end
  assert(#result[1] == n)
  assert(#result[2] == n)
  return result
end

local B1 = vecmath.bezier({-240,0}, {-80,80}, {80,-160}, {240,80})
local B2 = vecmath.bezier({-50,-150}, {-25,200}, {150,300}, {150,150})
local B3 = vecmath.bezier({-50,-150}, {-25,200}, {25,200}, {50,-150})
local B4 = vecmath.bezier({-50,-150}, {-25,400}, {25,-400}, {50,150})
local z = math.cos(math.pi / 4)
local B5 = vecmath.bezier({-200,-200,1}, {200*z,-200*z,z}, {200,200,1})
local B6 = vecmath.bezier({-150,-50}, {400,-25}, {-400,25}, {150,50})

local B7 = vecmath.bezier(B1):clip(0, 0.6)
local B8 = vecmath.bezier(B1):clip(0.2, 1)

local r = check(B1, B2, 1)
local r = check(B1, B3, 2)
local r = check(B1, B4, 3)
local r = check(B1, B5, 1)
local r = check(B4, B6, 9)
-- local r = check(B7, B8, 2)
-- assert(r.is_identical)
-- assert(math.abs(r[1][1] - 1/3) < epsilon)
-- assert(math.abs(r[1][2] - 1/1) < epsilon)
-- assert(math.abs(r[2][1] - 0/1) < epsilon)
-- assert(math.abs(r[2][2] - 1/2) < epsilon)

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
