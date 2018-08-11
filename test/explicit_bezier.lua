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
local bernstein = require "dromozoa.vecmath.bernstein"
local polynomial = require "dromozoa.vecmath.polynomial"
local quickhull = require "dromozoa.vecmath.quickhull"

local _ = element
local point2 = vecmath.point2
local point3 = vecmath.point3

local N = 64

local function draw_rational_quadratic_bezier(node, points)
  local p1 = points[1]
  local p2 = points[2]
  local p3 = points[3]
  local pd = path_data()

  for i = 0, N do
    local t = i / N
    local u = 1 - t

    local q = point2()
    local a = u * u
    local b = 2 * u * t
    local c = t * t
    local d = a * p1.z + b * p2.z + c * p3.z
    q:scale_add(a / d, p1, q)
    q:scale_add(b / d, p2, q)
    q:scale_add(c / d, p3, q)
    if i == 0 then
      pd:M(q.x, q.y)
    else
      pd:L(q.x, q.y)
    end
  end

  node[#node + 1] = _"path" {
    d = pd;
    fill = "none";
    stroke = "#333";
  }
end

local function draw_distance_polynomial(node, points, q)
  local p1 = points[1]
  local p2 = points[2]
  local p3 = points[3]
  local pd = path_data()

  local px = polynomial(bernstein(p1.x, p2.x, p3.x))
  local py = polynomial(bernstein(p1.y, p2.y, p3.y))
  local pz = polynomial(bernstein(p1.z, p2.z, p3.z))

  local dx = polynomial():deriv(px)
  local dy = polynomial():deriv(py)
  local dz = polynomial():deriv(pz)

  local dpx = polynomial():mul(dx, pz)
  dpx:sub(polynomial():mul(px, dz))

  local dpy = polynomial():mul(dy, pz)
  dpy:sub(polynomial():mul(py, dz))

  local qx = polynomial():sub(px, polynomial():mul(q.x, pz))
  local qy = polynomial():sub(py, polynomial():mul(q.y, pz))

  local d = dpx:mul(qx):add(dpy:mul(qy))

  local min
  local max

  for i = 0, N do
    local t = i / N
    local v = d:eval(t)
    if not min or min > v then
      min = v
    end
    if not max or max < v then
      max = v
    end
  end

  local h = math.max(math.abs(min), math.abs(max))
  print(min, max)

  local b = bernstein(d)
  local bp = {}
  for i = 1, #b do
    local t = (i - 1) / (#b - 1)
    bp[i] = point2(t, b[i])
  end
  local br = quickhull(bp, {})
  local pd = path_data()

  for i = 1, #br do
    local p = br[i]
    if i == 1 then
      pd:M(p.x * 320, p.y / h * 320)
    else
      pd:L(p.x * 320, p.y / h * 320)
    end
  end
  pd:Z()

  node[#node + 1] = _"path" {
    d = pd;
    fill = "#ccc";
    ["fill-opacity"] = 0.5;
    stroke = "none";
  }

  local pd = path_data()
  for i = 0, N do
    local t = i / N
    local v = d:eval(t) / h
    if i == 0 then
      pd:M(t * 320, v * 320)
    else
      pd:L(t * 320, v * 320)
    end
  end

  node[#node + 1] = _"path" {
    d = pd;
    fill = "none";
    stroke = "#333";
  }
end

local root = _"g" {
  transform = "translate(320, 320)";
}

local ex_root = _"g" {
  transform = "translate(640, 320)";
}

local q = point2(200, -200)
local q = point2(100, 100)

-- local points = {
--   point3(-200, -200, 1);
--   point3( 200, -200, 1);
--   point3( 400,  400, 2);
-- }

root[#root + 1] = _"circle" {
  cx = q.x;
  cy = q.y;
  r = 2;
  fill = "#333";
}

local z = math.cos(math.pi / 4)
local points = {
  point3(-200,   -200,   1);
  point3( 200*z, -200*z, z);
  point3( 200,    200,   1);
}

root[#root + 1] = _"path" {
  d = path_data():M(-200, -200):A(400, 400, 0, 0, 1, 200, 200);
  fill = "none";
  stroke = "#66c";
}

draw_rational_quadratic_bezier(root, points)
draw_distance_polynomial(ex_root, points, q)

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
