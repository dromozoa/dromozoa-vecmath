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
local path_data = require "dromozoa.svg.path_data"
local element = require "dromozoa.dom.element"
local space_separated = require "dromozoa.dom.space_separated"
local xml_document = require "dromozoa.dom.xml_document"

local verbose = os.getenv "VERBOSE" == "1"

local _ = element

local root = _"g" {}

local pd = path_data()
  :M(320, 320)
  :L(vecmath.point2(400, 380))
  :Q(320, 440, 240, 380)
  :Z()
  :M(80, 80)
  :L(560, 80)
  :A(240, 240, 0, false, true, 320, 320)
  :Z()
  :C(320, 120, 80, 160, 320, 200)
  :Z()

if verbose then
  print(tostring(pd))
end

root[#root + 1] = _"path" {
  d = pd;
  fill = "none";
  stroke = vecmath.color4f(0, 0, 0, 0.5);
}

local result = pd:bezier({})

for i = 1, #result do
  local pd = path_data()
  local b = result[i]
  local fill
  local stroke
  if b:is_rational() then
    fill = vecmath.color4f(1, 0, 0, 0.25)
    stroke = vecmath.color4f(1, 0, 0, 0.5)
  elseif b:size() == 2 then
    fill = "none"
    stroke = vecmath.color4f(0, 1, 0, 0.5)
  else
    fill = vecmath.color4f(0, 0, 1, 0.25)
    stroke = vecmath.color4f(0, 0, 1, 0.5)
  end
  for j = 1, b:size() do
    local p = b:get(j, vecmath.point2())
    if j == 1 then
      pd:M(p)
    else
      pd:L(p)
    end
  end
  root[#root + 1] = _"path" {
    d = pd;
    fill = fill;
    stroke = stroke;
  }
end

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
