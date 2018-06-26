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
local vector3 = vecmath.vector3
local matrix3 = vecmath.matrix3

local N = 16

local function cubic_bezier(P, t)
  local p1, p2, p3, p4 = unpack(P)
  local u = 1 - t
  local p = vector2()
  p:scale_add(t * t * t, p4, p)
  p:scale_add(3 * u * t * t, p3, p)
  p:scale_add(3 * u * u * t, p2, p)
  p:scale_add(u * u * u, p1, p)
  return p
end

local function cubic_bezier_d(P, t)
  local p1, p2, p3, p4 = unpack(P)
  local u = 1 - t
  local v = vector2()
  v:scale_add(t * t, p4, v)
  v:scale_add(3 * t * (u - 1/3), p3, v)
  v:scale_add(-3 * (t - 1/3) * u, p2, v)
  v:scale_add(-u * u, p1, v)
  v:scale(3)
  return v
end

local function rot90(v)
  v:set(-v.y, v.x)
  return v
end

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

  local m = matrix3(1)
  m.m11 = p1.y - p2.y
  m.m12 = p4.y - p3.y
  m.m21 = p2.x - p1.x
  m.m22 = p3.x - p4.x
  if m:determinant() ~= 0 then
    m:invert()
    local c = vector3(p4.x, p4.y, 1):sub{ p1.x, p1.y, 1 }
    m:transform(c)
    c:scale(1/3)
    if c.x < 0 then
      c0 = math.max(c.x, -c0)
    else
      c0 = math.min(c.x, c0)
    end
    if c.y < 0 then
      c1 = math.max(c.y, -c1)
    else
      c1 = math.min(c.y, c1)
    end
  end

  local q1 = point2():add(cubic_bezier(P, 0), rot90(cubic_bezier_d(P, 0)):scale(c0))
  local q4 = point2():add(cubic_bezier(P, 1), rot90(cubic_bezier_d(P, 1)):scale(c1))
  local qa = point2():add(cubic_bezier(P, 1/3), rot90(cubic_bezier_d(P, 1/3)):scale(c0*2/3 + c1*1/3))
  local qb = point2():add(cubic_bezier(P, 2/3), rot90(cubic_bezier_d(P, 2/3)):scale(c0*1/3 + c1*2/3))
  local qc = point2():add(cubic_bezier(P, 1/2), rot90(cubic_bezier_d(P, 1/2)):scale(c0*1/2 + c1*1/2))
  local q2 = point2()
  q2:scale_add(3, qa, q2)
  q2:scale_add(-3/2, qb, q2)
  q2:scale_add(-5/6, q1, q2)
  q2:scale_add(1/3, q4, q2)
  local q3 = point2()
  q3:scale_add(8, qc, q3)
  q3:sub(q1)
  q3:sub(q4)
  q3:scale_add(-3, q2, q3)
  q3:scale(1/3)

  -- node[#node + 1] = _"circle" { cx = qa.x, cy = qa.y, r = 4 }
  -- node[#node + 1] = _"circle" { cx = qb.x, cy = qb.y, r = 4 }
  -- node[#node + 1] = _"circle" { cx = qc.x, cy = qc.y, r = 4 }

  node[#node + 1] = _"path" {
    d = path_data():M(q1.x, q1.y):C(q2.x, q2.y, q3.x, q3.y, q4.x, q4.y);
    fill = "none";
    stroke = "#333";
  }

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
    ["stroke-opacity"] = 0.5;
  }
end

local P = {
  point2(-100, 100);
  point2( -25, 200);
  point2(  25, 200);
  point2( 100, 200);
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
