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

local _ = element
local point2 = vecmath.point2
local point3 = vecmath.point3

local N = 16

local function rational_quadratic_bezier(node, P)
  local p1 = P[1]
  local p2 = P[2]
  local p3 = P[3]

  local pd = path_data()

  for i = 0, N do
    local t = i / N
    local u = 1 - t

    local q = point2()
    local a = u * u * p1.z
    local b = 2 * u * t * p2.z
    local c = t * t * p3.z
    local d = a + b + c
    q:scale_add(a / d, p1, q)
    q:scale_add(b / d, p2, q)
    q:scale_add(c / d, p3, q)
    print(q)
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

local root = _"g" {
  transform = "matrix(1 0 0 -1 320 320)";
}

root[#root + 1] = _"path" {
  d = path_data():M(300, 0):A(300, 300, 0, 0, 1, 0, 300);
  fill = "none";
  stroke = "#F33";
  ["stroke-width"] = 2;
}

-- rational_quadratic_bezier(root, {
--   point3(300,   0, 1);
--   point3(300, 300, math.cos(math.pi / 4));
--   point3(  0, 300, 1);
-- })

rational_quadratic_bezier(root, {
  point3(300,   0, 1);
  point3(300, 300, 1);
  point3(  0, 300, 2);
})

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
