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

  local D = bezier(B):deriv()
  local p = B:get(1, point2())
  local q = B:get(B:size(), point2())
  local u = D:get(1, vector2())
  local v = D:get(D:size(), vector2())

  local m = matrix2(-u.y, v.y, u.x, -v.x)
  v:sub(q, p)
  if m:determinant() == 0 then
    print "skip"
    return
  end

  m:invert()
  m:transform(v)
  print(tostring(v))

  local C = polynomial(v.x, v.y - v.x)

  if not B:is_rational() then
    local PX = B[1]:get(polynomial())
    local PY = B[2]:get(polynomial())
    local QX = D[2]:get(polynomial()):mul(-1)
    local QY = D[1]:get(polynomial())

    QX:mul(C, QX)
    QY:mul(C, QY)

    PX:add(QX)
    PY:add(QY)

    local F = bezier()
    F[1]:set(PX)
    F[2]:set(PY)

    print(tostring(F:get(1, point2())))
    print(tostring(F:get(F:size(), point2())))

    draw_bezier(node, F, "#F33")
  end
end

draw(bezier({-120,0}, {-40,40}, {40,-80}, {120,40}))
draw(bezier({145,-15}, {147.5,20}, {165,30}, {165,15}))
draw(bezier({-150,-150}, {-25,200}, {25,200}, {150,-150}))
draw(bezier({-50,-150}, {-25,400}, {25,-400}, {50,150}))
local z = math.cos(math.pi / 4)
draw(bezier({-200,-200,1}, {200*z,-200*z,z}, {200,200,1}))

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
