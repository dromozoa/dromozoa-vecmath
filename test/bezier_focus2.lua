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

local dom = require "dromozoa.dom"
local vecmath = require "dromozoa.vecmath"
local svg = require "dromozoa.svg"

local verbose = os.getenv "VERBOSE" == "1"
local _ = dom.element

local root = _"g" {}

local r = 1000
local w = math.cos(math.pi / 4)
local b3 = vecmath.bezier(
  { r,   0,   1 },
  { r*w, r*w, w },
  { 0,   r,   1 })

local b4 = vecmath.bezier(
  { 0,     -r,   1   },
  { r*2/3, -r/3, 1/3 },
  { r*2/3,  r/3, 1/3 },
  { 0,      r,   1   })

local b = b4
local d = vecmath.bezier():deriv(b)

local dot = {}

local n = 64
for i = 0, n do
  local t = i / n
  local p = b:eval(t, vecmath.point2())
  local u = d:eval(t, vecmath.vector2())
  local v = vecmath.vector2(u.y, -u.x)

  dot[#dot + 1] = u:dot(p)

  p:scale(25)
  local q = vecmath.point2(p):add(v:scale(25))
  root[#root + 1] = _"path" {
    d = svg.path_data():M(p):L(q);
    fill = "none";
    stroke = "#000";
  }
end

local min = dot[1]
local max = min

for i = 2, #dot do
  local v = dot[i]
  if min > v then
    min = v
  end
  if max < v then
    max = v
  end
end

print(("%.17g"):format(min))
print(("%.17g"):format(max))

local svg = _"svg" {
  xmlns = "http://www.w3.org/2000/svg";
  ["xmlns:xlink"] ="http://www.w3.org/1999/xlink";
  version = "1.1";
  width = 640;
  height = 640;
  _"g" {
    transform = "translate(320 320)";
    root;
  };
}

local doc = dom.xml_document(svg)
local out = assert(io.open("test.svg", "w"))
doc:serialize(out)
out:write "\n"
out:close()
