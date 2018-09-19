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

local arcto = require "dromozoa.svg.arcto"
local path_data = require "dromozoa.svg.path_data"

local verbose = os.getenv "VERBOSE" == "1"

local _ = element

local p1 = vecmath.point2(240, 280)
local p2 = vecmath.point2(400, 360)
local rx = 200
local ry = 50
local r = 30

local function g(node, b, stroke)
  local pd = path_data()
  for i = 1, b:size() do
    local p = b:get(i, vecmath.point2())
    if verbose then
      print(tostring(p))
    end
    if i == 1 then
      pd:M(p)
    else
      pd:L(p)
    end
  end
  node[#node + 1] = _"path" {
    d = pd;
    fill = "none";
    stroke = stroke;
  }
end

local function f(node, large_arc, sweep, stroke)
  node[#node + 1] = _"path" {
    d = space_separated {
      "M", p1.x, p1.y;
      "A", rx, ry, r, large_arc, sweep, p2.x, p2.y;
    };
    fill = "none";
    stroke = stroke;
  }

  local A = arcto(rx, ry, r, large_arc == 1, sweep == 1, p2)
  local result = {}
  A:bezier(nil, p1, result)
  g(node, result[1], stroke)
  if result[2] then
    g(node, result[2], stroke)
  end
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
