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

local N = 128

local function draw_cubic_bezier(node, P)
  local p1, p2, p3, p4 = unpack(P)

  local d = path_data()
  d:M(p1.x, p1.y):C(p2.x, p2.y, p3.x, p3.y, p4.x, p4.y)

  node[#node + 1] = _"path" {
    d = d;
    fill = "none";
    stroke = "#333";
  }

  local c0 = 10
  local c1 = 10

  local m11 = p1.y - p2.y
  local m12 = p4.y - p3.y
  local m21 = p2.x - p1.x
  local m22 = p3.x - p4.x
  local det = m11 * m22 - m12 * m21
  if det ~= 0 then
    local n11 = m22 / det
    local n12 = -m12 / det
    local n21 = -m21 / det
    local n22 = m11 / det
    local x = p4.x - p1.x
    local y = p4.y - p1.y
    local cx = (n11 * x + n12 * y) / 3
    local cy = (n21 * x + n22 * y) / 3
    if cx < 0 then
      c0 = math.max(cx, -c0)
    else
      c0 = math.min(cx, c0)
    end
    if cy < 0 then
      c1 = math.max(cy, -c1)
    else
      c1 = math.min(cy, c1)
    end
  end

  local d1 = path_data()
  local d2 = path_data()
  for i = 0, N do
    local t = i / N
    local u = 1 - t

    local p = point2()
    p:scale_add(u * u * u, p1, p)
    p:scale_add(3 * u * u * t, p2, p)
    p:scale_add(3 * u * t * t, p3, p)
    p:scale_add(t * t * t, p4, p)

    local v = vector2()
    v:scale_add(t * t, p4, v)
    v:scale_add(3 * t * (u - 1/3), p3, v)
    v:scale_add(- 3 * (t - 1/3) * u, p2, v)
    v:scale_add(- u * u, p1, v)
    v:scale(3)
    v.x, v.y = -v.y, v.x
    v:scale(c0 * u + c1 * t)

    d1:M(p.x, p.y):L(p.x + v.x, p.y + v.y)
    if i == 0 then
      d2:M(p.x + v.x, p.y + v.y)
    else
      d2:L(p.x + v.x, p.y + v.y)
    end
  end

  node[#node + 1] = _"path" {
    d = d1;
    fill = "none";
    stroke = "#F33";
    ["stroke-opacity"] = 0.5;
  }

  node[#node + 1] = _"path" {
    d = d2;
    fill = "none";
    stroke = "#F33";
  }
end

local P = {
  point2(-200, 100);
  point2( -25, 200);
  point2(  25, 200);
  point2( 200, 100);
}

local root = _"g" {
  transform = "translate(320, 320)";
}

draw_cubic_bezier(root, P)

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
