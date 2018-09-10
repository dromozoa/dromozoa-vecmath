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
local bezier_focus = require "dromozoa.vecmath.bezier_focus"

local point2 = vecmath.point2
local vector2 = vecmath.vector2
local bezier = vecmath.bezier

local verbose = os.getenv "VERBOSE" == "1"
local epsilon = 1e-5
local not_check = os.getenv "NOT_CHECK" == "1"

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

local root = _"g" {}

local y = 0

local function check(B1, B2, n, is_identical)
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

  local U1 = {}
  local U2 = {}

  local result = bezier_focus(B1, B2, 0, 1, 0, 1, { U1, U2 })

  for i = 1, #U1 do
    local p = B1:eval(U1[i], point2())
    local q = B2:eval(U2[i], point2())
    if verbose then
      print(tostring(p), tostring(q))
    end
    if p:epsilon_equals(q, 1) then
      node[#node + 1] = _"circle" {
        cx = (p.x + q.x) / 2;
        cy = (p.y + q.y) / 2;
        r = 2;
        fill = "#33C";
      }
    else
      node[#node + 1] = _"line" {
        x1 = p.x;
        y1 = p.y;
        x2 = q.x;
        y2 = q.y;
        stroke = "#33C";
      }
    end
  end

  if verbose then
    print("##", #U1, #U2)
  end

  if not not_check then
    assert(#U1 == n)
    assert(#U2 == n)
  end

  local D1 = bezier(B1):deriv()
  local D2 = bezier(B2):deriv()
  for i = 1, #U1 do
    local d1 = D1:eval(U1[i], vector2()):normalize()
    local d2 = D2:eval(U2[i], vector2()):normalize()
    if verbose then
      print("D", i, tostring(d1), tostring(d2))
    end
    if not not_check then
      assert(d1:epsilon_equals(d2, epsilon) or vector2(d1):negate():epsilon_equals(d2, epsilon))
    end
  end
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
local r = check(B1, B3, 1)
local r = check(B1, B4, 2)

local r = check(B1, B5, 1)

local r = check(B4, B6, 16)

local r = check(B7, B8, 2, true)

local B1 = vecmath.bezier({-200,0},{200,0})
local B2 = vecmath.bezier({200,0},{200,-200})
local r = check(B1, B2, 0)

local B1 = vecmath.bezier({-200,0},{0,200},{200,0})
local B2 = vecmath.bezier({200,0},{200,-200})
local r = check(B1, B2, 0)

local B1 = vecmath.bezier({-200,0},{0,200},{200,0})
local B2 = vecmath.bezier({200,0},{100,-100},{200,-200})
local r = check(B1, B2, 0)

local B1 = vecmath.bezier({-200,0},{-50,200},{50,-200},{200,0})
local B2 = vecmath.bezier({-200,0},{200,0})
local r = check(B1, B2, 2)

local B1 = vecmath.bezier({-150, 0},{-50,200},{50,-200},{150,0})
local B2 = vecmath.bezier({-200,0},{200,0})
local r = check(B1, B2, 2)

--TODO
local B1 = vecmath.bezier({-150, 0},{-50,200},{50,-200},{150,0})
local B2 = vecmath.bezier({-200,0},{199,0})
local r = check(B1, B2, 2)

local B1 = vecmath.bezier({-150, 0},{-50,200},{50,-200},{150,10})
local B2 = vecmath.bezier({-200,0},{200,-0})
local r = check(B1, B2, 2)

local B1 = vecmath.bezier({-200,0},{-50,200},{50,-200},{200,0})
local B2 = vecmath.bezier({-200,0},{-100,200},{100,-200},{200,0})
local r = check(B1, B2, 4)

local B1 = vecmath.bezier({-200,0},{-50,200},{50,-200},{200,0})
local B2 = vecmath.bezier({-200,0},{-50,100},{50,-100},{200,0})
local r = check(B1, B2, 2)

local B1 = vecmath.bezier({-200,-100},{0,240},{200,-100})
local B2 = vecmath.bezier({-200,100},{0,-200},{200,100})
local r = check(B1, B2, 1)

local B1 = vecmath.bezier({-200,0},{-50,200},{50,200},{200,0})
local B2 = vecmath.bezier({-200,0},{-200,200},{200,200},{200,0})
local r = check(B1, B2, 3)

local B1 = vecmath.bezier({-200,0},{-50,200+1e-9},{50,200+1e-9},{200,0})
local B2 = vecmath.bezier({-200,0},{-100,200},{100,200},{200,0})
local r = check(B1, B2, 3)

local B1 = vecmath.bezier({-200,0},{0,200},{200,0})
local B2 = vecmath.bezier({-200,-50},{0,-100},{200,-50})
local r = check(B1, B2, 1)

local B1 = vecmath.bezier({-200,0},{0,200},{200,0})
local B2 = vecmath.bezier({-200,-50},{200,-50})
local r = check(B1, B2, 1)

local B1 = vecmath.bezier({-150,-200},{0,400},{150,-200})
local B2 = vecmath.bezier({-200,-50},{200,-50})
local r = check(B1, B2, 1)

local B1 = vecmath.bezier({-150,-200},{0,600},{150,-200})
local B2 = vecmath.bezier({-200,-150},{600,0},{-200,150})
local r = check(B1, B2, 5)

local B1 = vecmath.bezier({-150,-200},{0,600},{150,-200})
local B2 = vecmath.bezier({-300,-150},{1200,-50},{-1200,50},{300,150})
local r = check(B1, B2, 7)

local B1 = vecmath.bezier({-150,-300},{-50,1200},{50,-1200},{150,300})
local B2 = vecmath.bezier({-300,-150},{1200,-50},{-1200,50},{300,150})
local r = check(B1, B2, 16)

local B1 = vecmath.bezier({-100,-300},{-50,1200},{0,-1800},{50,1200},{100,-300})
local B2 = vecmath.bezier({-300,-100},{1200,-50},{-1800,0},{1200,50},{-300,100})
local r = check(B1, B2, 29)

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
