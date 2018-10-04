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
local svg = require "dromozoa.svg"

local point2 = vecmath.point2
local bezier = vecmath.bezier

local verbose = os.getenv "VERBOSE" == "1"
local epsilon = 1e-5
local epsilon_identical = 1e-5
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

local function draw_line(node, a, b, c, d, stroke)
  if b ~= 0 then
    local x1 = -320
    local y1 = -(a * x1 + c + d) / b
    local x2 = 320
    local y2 = -(a * x2 + c + d) / b
    if verbose then
      print("draw_line", x1, y1, x2, y2)
    end
    node[#node + 1] = _"line" {
      x1 = x1;
      y1 = y1;
      x2 = x2;
      y2 = y2;
      fill = "none";
      stroke = stroke;
    }
  end
end

local root = _"g" {}

local y = 0

local function check(B1, B2, n, is_identical, debug_code)
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

  local result = bezier_clipping(B1, B2)
  local U1 = result[1]
  local U2 = result[2]

  draw_points(node, B1, U1, "#66C")
  draw_points(node, B2, U2, "#C66")

  if debug_code then
    if verbose then
      print("debug_code", debug_code)
    end
    if debug_code == 1 then
      draw_line(node, 100, 100, -20000, 1250, "#F33")
      draw_line(node, 100, 100, -20000, 0, "#F33")
    elseif debug_code == 2 then
      draw_line(node, 80, -480, -19200, -11377.777777778, "#F33")
      draw_line(node, 80, -480, -19200, 45511.111111111, "#F33")
    elseif debug_code == 3 then
      draw_line(node, 100, -100, -0, 1250, "#F33")
      draw_line(node, 100, -100, -0, 0, "#33F")
    end
  end

  local e2 = 0
  for i = 1, #U1 do
    if verbose then
      print(("u %.17g\t%.17g"):format(U1[i], U2[i]))
    end
    local p = B1:eval(U1[i], point2())
    local q = B2:eval(U2[i], point2())
    e2 = e2 + p:distance_squared(q)
  end
  e2 = e2 / #U1
  local e = math.sqrt(e2)
  if verbose then
    print("E", e)
    print("!", #U1, n)
  end

  if not not_check then
    if result.is_identical then
      assert(is_identical)
      assert(e <= epsilon_identical)
    else
      assert(not is_identical)
      assert(e <= epsilon)
    end

    assert(#U1 == n)
    assert(#U2 == n)
  end
  return result
end

repeat
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
  local r = check(B1, B5, 1, nil, 2)
  local r = check(B4, B6, 9)
  local r = check(B7, B8, 2, true)
  if verbose then
    print(math.abs(r[1][1] - 1/3))
    print(math.abs(r[1][2] - 1/1))
    print(math.abs(r[2][1] - 0/1))
    print(math.abs(r[2][2] - 1/2))
  end
  if not not_check then
    assert(math.abs(r[1][1] - 1/3) < epsilon_identical)
    assert(math.abs(r[1][2] - 1/1) < epsilon_identical)
    assert(math.abs(r[2][1] - 0/1) < epsilon_identical)
    assert(math.abs(r[2][2] - 1/2) < epsilon_identical)
  end

  local B1 = vecmath.bezier({-200,0},{200,0})
  local B2 = vecmath.bezier({200,0},{200,-200})
  local r = check(B1, B2, 1)

  local B1 = vecmath.bezier({-200,0},{0,200},{200,0})
  local B2 = vecmath.bezier({200,0},{200,-200})
  local r = check(B1, B2, 1)

  local B1 = vecmath.bezier({-200,0},{0,200},{200,0})
  local B2 = vecmath.bezier({200,0},{100,-100},{200,-200})
  local r = check(B1, B2, 1)

  local B1 = vecmath.bezier({-200,0},{-50,200},{50,-200},{200,0})
  local B2 = vecmath.bezier({-200,0},{200,0})
  local r = check(B1, B2, 3)

  local B1 = vecmath.bezier({-150, 0},{-50,200},{50,-200},{150,0})
  local B2 = vecmath.bezier({-200,0},{200,0})
  local r = check(B1, B2, 3)

  local B1 = vecmath.bezier({-150, 0},{-50,200},{50,-200},{150,0})
  local B2 = vecmath.bezier({-200,0},{199,0})
  local r = check(B1, B2, 3)

  local B1 = vecmath.bezier({-150, 0},{-50,200},{50,-200},{150,10})
  local B2 = vecmath.bezier({-200,0},{200,-0})
  local r = check(B1, B2, 3)

  local B1 = vecmath.bezier({-200,0},{-50,200},{50,-200},{200,0})
  local B2 = vecmath.bezier({-200,0},{-100,200},{100,-200},{200,0})
  local r = check(B1, B2, 5)

  local B1 = vecmath.bezier({-200,0},{-50,200},{50,-200},{200,0})
  local B2 = vecmath.bezier({-200,0},{-50,100},{50,-100},{200,0})
  local r = check(B1, B2, 3)

  local B1 = vecmath.bezier({-200,-100},{0,240},{200,-100})
  local B2 = vecmath.bezier({-200,100},{0,-200},{200,100})
  local r = check(B1, B2, 2)

  local B1 = vecmath.bezier({-200,0},{-50,200},{50,200},{200,0})
  local B2 = vecmath.bezier({-200,0},{-200,200},{200,200},{200,0})
  local r = check(B1, B2, 3)

  local B1 = vecmath.bezier({-200,0},{-50,200+1e-9},{50,200+1e-9},{200,0})
  local B2 = vecmath.bezier({-200,0},{-100,200},{100,200},{200,0})
  if verbose then
    print("!1", tostring(B1:eval(0.5, point2())))
    print("!2", tostring(B2:eval(0.5, point2())))
  end
  local r = check(B1, B2, 3)

  local B1 = vecmath.bezier():set_catmull_rom({50,50},{50,50},{50,150},{50,150})
  local B2 = vecmath.bezier({87.5,65},{12.5,65})
  local B3 = vecmath.bezier({12.5,135},{87.5,135})
  local r = check(B1, B2, 1)
  local B4 = vecmath.bezier(B1):clip(r[1][1], 1)
  local r = check(B1, B3, 1)
  local r = check(B4, B3, 1)

  local B1 = vecmath.bezier():set_catmull_rom({100,50},{100,50},{150,150},{150,150})
  local B2 = vecmath.bezier({137.5,65},{62.5,65})
  local r = check(B1, B2, 1)

  local B1 = vecmath.bezier():set_catmull_rom({50,50},{50,50},{150,150},{150,150})
  local B2 = vecmath.bezier({87.5,65},{12.5,65})
  local B3 = vecmath.bezier({112.5,135},{187.5,135})
  local r = check(B1, B2, 1)
  local B4 = vecmath.bezier(B1):clip(r[1][1], 1)
  local r = check(B1, B3, 1)
  local r = check(B4, B3, 1)

  local B1 = vecmath.bezier():set_catmull_rom({150,50},{150,50},{50,150},{50,250})
  local B2 = svg.path_data():M(135,65):A(7.5,7.5,0,false,true,127.5,57.5):bezier({})[1]
  if verbose then
    print(("=-"):rep(40))
    for i = 1, B1:size() do
      print("B1", i, tostring(B2:get(i, point2())))
    end
    for i = 1, B2:size() do
      print("B2", i, tostring(B2:get(i, point2())))
    end
  end
  local r = check(B1, B2, 1, nil, 1)

  local B1 = vecmath.bezier():set_catmull_rom({0,50},{0,50},{150,150},{150,150})
  local B2 = svg.path_data():M(18.75,57.5):A(7.5,7.5,0,false,true,11.25,65):bezier({})[1]
  local r = check(B1, B2, 1)

  local B1 = vecmath.bezier():set_catmull_rom({400,50},{400,50},{550,150},{550,150})
  local B2 = svg.path_data():M(418.75,57.5):A(7.5,7.5,0,false,true,411.25,65):bezier({})[1]
  local r = check(B1, B2, 1)

  local B1 = vecmath.bezier():set_catmull_rom({50,-50},{50,50},{150,150},{150,150})
  local B2 = svg.path_data():M(127.5,142.5):A(7.5,7.5,0,false,true,135,135):bezier({})[1]
  local r = check(B1, B2, 1, nil, 3)

  local B1 = vecmath.bezier():set_catmull_rom({50,250},{50,350},{150,450},{150,450})
  local B2 = svg.path_data():M(127.5,442.5):A(7.5,7.5,0,false,true,135,435):bezier({})[1]
  local r = check(B1, B2, 1)

  local B1 = vecmath.bezier({200,50},{150,100})
  local B2 = svg.path_data():M(192,66):A(8,8,0,false,true,184,58):bezier({})[1]
  local r = check(B1, B2, 1)

  local B1 = vecmath.bezier({50,75},{100,37.5})
  local B2 = svg.path_data():M(58,63):A(4,4,0,false,true,62,67):bezier({})[1]
  local r = check(B1, B2, 1)
until true

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
