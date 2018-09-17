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

local vecmath = require "dromozoa.vecmath"
local element = require "dromozoa.dom.element"
local space_separated = require "dromozoa.dom.space_separated"
local xml_document = require "dromozoa.dom.xml_document"

local verbose = os.getenv "VERBOSE" == "1"

local _ = element

local p1 = vecmath.point2(240, 280)
local p2 = vecmath.point2(400, 360)
local rx = 200
local ry = 50
local r = 30

local M = vecmath.matrix2():rot(r * math.pi / 180):mul {rx, 0, 0, ry}
local N = vecmath.matrix2():invert(M)
local P = vecmath.point2():add(p1, p2):scale(0.5)
local V = vecmath.vector2():sub(p1, p2)
N:transform(V)
local X = V.x
local Y = V.y
local X2Y2 = X * X + Y * Y

local function f(node, large_arc, sweep, stroke)
  node[#node + 1] = _"path" {
    d = space_separated {
      "M", p1.x, p1.y;
      "A", rx, ry, r, large_arc, sweep, p2.x, p2.y;
    };
    fill = "none";
    stroke = stroke;
  }

  local sin_b = math.sqrt(X2Y2) / 2
  local cos_b = math.sqrt(4 - X2Y2) / 2

  if large_arc == 1 then
    cos_b = -cos_b
  end
  if sweep == 1 then
    sin_b = -sin_b
  end

  -- if large_arc == 1 then
  --   cos_b = -cos_b
  -- end
  -- if sweep == 0 then
  --   sin_b = -sin_b
  -- end

  local sin_a = - X / (2 * sin_b)
  local cos_a = Y / (2 * sin_b)

  local v = vecmath.vector2(cos_a, sin_a):scale(cos_b)
  M:transform(v)

  local c = vecmath.point2(P):sub(v)
  if verbose then
    print(tostring(c))
  end

  node[#node + 1] = _"circle" {
    cx = c.x;
    cy = c.y;
    r = large_arc == 1 and 4 or 2;
    fill = "none";
    stroke = stroke;
  }

  local p = vecmath.point2(cos_a, sin_a)
  M:transform(p)
  p:add(c)

  node[#node + 1] = _"circle" {
    cx = p.x;
    cy = p.y;
    r = 2;
    fill = "none";
    stroke = stroke;
  }
end

local root = _"g" {}

f(root, 0, 0, "#333")
f(root, 0, 1, "#33C")
f(root, 1, 0, "#C33")
f(root, 1, 1, "#C3C")

local doc = xml_document(_"svg" {
  version = "1.1";
  xmlns = "http://www.w3.org/2000/svg";
  width = 640;
  height = 640;
  _"rect" {
    x = 0;
    y = 0;
    width = 640;
    height = 640;
    fill = "#CCC";
  };
  root;
})

local out = assert(io.open("test.svg", "w"))
doc:serialize(out)
out:write "\n"
out:close()
