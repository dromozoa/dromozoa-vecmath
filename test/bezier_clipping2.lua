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

local function fat_line(b, v1)
  local n = b:size()
  local p1 = b:get(1, vecmath.point2())
  local p2 = b:get(n, vecmath.point2())

  -- [TODO] normalize not required?
  v1:sub(p2, p1):normalize()

  local d_min = 0
  local d_max = 0
  for i = 2, n - 1 do
    local p = b:get(i, vecmath.point2())
    local v = vecmath.vector2(p):sub(p1)
    local d = v1:cross(v)

    if d_min > d then
      d_min = d
    end
    if d_max < d then
      d_max = d
    end
  end

  if not b:is_rational() then -- non rational
    if n == 3 then -- quadratic
      d_min = d_min / 2
      d_max = d_max / 2
    elseif n == 4 then -- cubic
      if d_min == 0 or d_max == 0 then
        d_min = d_min * 3 / 4
        d_max = d_max * 3 / 4
      else
        d_min = d_min * 4 / 9
        d_max = d_max * 4 / 9
      end
    end
  end

  return p1, v1, d_min, d_max
end

local function bezier_clipping(b1, b2, ex_node)
  local p1, v1, d_min, d_max = fat_line(b2, vecmath.vector2())

  local rx = 320
  local ry =  80 / math.max(math.abs(d_min), d_max)

  -- draw explicit min/max
  local pd = path_data()
  pd:M(0, d_max * ry):L(rx, d_max * ry)
  pd:M(0, d_min * ry):L(rx, d_min * ry)
  ex_node[#ex_node + 1] = _"path" {
    d = pd;
    fill = "none";
    stroke = "#33c";
  }

  -- draw explicit
  local pd = path_data()

  local p = b1:eval(0, vecmath.point2())
  local v = vecmath.vector2(p):sub(p1)
  local d = v1:cross(v)
  -- print(tostring(p), d)
  pd:M(0, d * ry)
  for i = 1, n do
    local t = i / n
    local p = b1:eval(t, vecmath.point2())
    local v = vecmath.vector2(p):sub(p1)
    local d = v1:cross(v)
    -- print(tostring(p), d)
    pd:L(t * rx, d * ry)
  end

  ex_node[#ex_node + 1] = _"path" {
    d = pd;
    fill = "none";
    stroke = "#333";
  }

  if not b1:is_rational() then -- non rational
    local q = {}

    local n = b1:size()
    for i = 1, n do
      local p = b1:get(i, vecmath.point2())
      local t = (i - 1) / (n - 1)
      local v = vecmath.vector2(p):sub(p1)
      local d = v1:cross(v)
      q[i] = vecmath.point2(t, d)
    end

    local pd = path_data()
    local r = vecmath.quickhull(q, {})
    for i = 1, #r do
      local p = r[i]
      if i == 1 then
        pd:M(p.x * rx, p.y * ry)
      else
        pd:L(p.x * rx, p.y * ry)
      end
    end
    ex_node[#ex_node + 1] = _"path" {
      d = pd:Z();
      fill = "#c33";
      ["fill-opacity"] = 0.25;
      stroke = "none";
    }
  else
    -- [TODO] impl
  end

  print(tostring(p1), tostring(v1), d_min, d_max)
end

local function draw_fat_line(node, b)
  local p1, v1, d_min, d_max = fat_line(b, vecmath.vector2())

  local n = b:size()
  local p2 = b:get(n, vecmath.point2())

  local pd = path_data()
  pd:M(p1.x, p1.y):L(p2.x, p2.y)
  node[#node + 1] = _"path" {
    d = pd;
    fill = "none";
    stroke = "#c33";
  }

  local v2 = vecmath.vector2(-v1.y, v1.x)
  local q1 = vecmath.point2():scale_add(d_min, v2, p1)
  local q2 = vecmath.point2():scale_add(d_min, v2, p2)
  local q3 = vecmath.point2():scale_add(d_max, v2, p2)
  local q4 = vecmath.point2():scale_add(d_max, v2, p1)

  local pd = path_data()
  pd:M(q1.x, q1.y):L(q2.x, q2.y):L(q3.x, q3.y):L(q4.x, q4.y):Z()
  node[#node + 1] = _"path" {
    d = pd;
    fill = "#c33";
    ["fill-opacity"] = 0.25;
    stroke = "none";
  }
end

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

  -- control points
  --[[
  local pd = path_data()

  local p = {}
  for i = 1, b:size() do
    p[i] = b:get(i, vecmath.point2())
  end
  local q = vecmath.quickhull(p, {})

  local p = q[1]
  pd:M(p.x, p.y)
  for i = 2, #q do
    local p = q[i]
    pd:L(p.x, p.y)
  end

  node[#node + 1] = _"path" {
    d = pd:Z();
    fill = "#ccc";
    ["fill-opacity"] = 0.5;
    stroke = "none";
  }
  ]]

  draw_fat_line(node, b)
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
draw_bezier(root, b2)
-- draw_bezier(root, b3)

bezier_clipping(b1, b2, ex_root)

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
