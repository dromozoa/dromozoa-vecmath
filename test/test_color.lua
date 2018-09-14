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

local color3b = require "dromozoa.vecmath.color3b"
local color3f = require "dromozoa.vecmath.color3f"
local color4b = require "dromozoa.vecmath.color4b"
local color4f = require "dromozoa.vecmath.color4f"

local verbose = os.getenv "VERBOSE" == "1"

assert(tostring(color3b(255, 127, 63)) == "#FF7F3F")
assert(tostring(color3b(255, 34, 0)) == "#F20")
assert(tostring(color3f(1, 0, 0x33/0xFF)) == "#F03")
assert(tostring(color3f(1, 0.5, 0.25)) == "rgb(100%,50%,25%)")

assert(tostring(color4b(0xFF, 0xFF, 0x00, 127.5)) == "rgba(255,255,0,0.5)")
assert(tostring(color4b(255, 127, 63, 255)) == "#FF7F3F")
assert(tostring(color4b(255, 34, 0, 255)) == "#F20")
assert(tostring(color4f(1, 0, 0x33/0xFF, 1)) == "#F03")
assert(tostring(color4f(1, 0.5, 0.25, 1)) == "rgb(100%,50%,25%)")
assert(tostring(color4f(1, 0.5, 0.25, 0.75)) == "rgba(100%,50%,25%,0.75)")

local c = color4f(42, -69, 0x66/0xFF, 0.5)
if verbose then
  print(tostring(c))
end
assert(tostring(c) == "rgba(255,0,102,0.5)")
-- assert(tostring(colors.blue) == "#00F")
-- assert(tostring(colors.silver) == "#C0C0C0")
-- assert(tostring(colors.transparent) == "rgba(0,0,0,0)")
-- assert(tostring(color4f(1, 0, 0, 0.5):interpolate(colors.lime, 0.5)) == "rgba(50%,50%,0%,0.75)")

local c = color3b(25.5, 12.75, 255)
if verbose then
  print(tostring(c))
end
assert(tostring(c) == "rgb(10%,5%,100%)")

local c = color3f(-42, 0.5, 666)
if verbose then
  print(tostring(c))
end
assert(tostring(c) == "rgb(0%,50%,100%)")

local c = color4b(25.5, 12.75, 255, 255)
if verbose then
  print(tostring(c))
end
assert(tostring(c) == "rgb(10%,5%,100%)")

local c = color4b(25.5, 12.75, 255, 127.5)
if verbose then
  print(tostring(c))
end
assert(tostring(c) == "rgba(10%,5%,100%,0.5)")

local c = color3f(1, 0, 0x33/0xFF)
assert(c.is_color3f)
local c = color3b(c)
assert(c.is_color3b)
assert(c.x == 0xFF)
assert(c.y == 0x00)
assert(c.z == 0x33)
assert(tostring(c) == "#F03")

local c = color3b(0xFF, 0x00, 0x33)
assert(c.is_color3b)
local c = color3f(c)
assert(c.is_color3f)
assert(c.x == 1)
assert(c.y == 0)
assert(c.z == 0x33/0xFF)
if verbose then
  print(tostring(c))
end
assert(tostring(c) == "#F03")

local c = color4f(1, 0, 0x33/0xFF, 1)
assert(c.is_color4f)
local c = color4b(c)
assert(c.is_color4b)
assert(c.x == 0xFF)
assert(c.y == 0x00)
assert(c.z == 0x33)
assert(c.w == 0xFF)
assert(tostring(c) == "#F03")

local c = color4b(0xFF, 0x00, 0x33, 0xFF)
assert(c.is_color4b)
local c = color4f(c)
assert(c.is_color4f)
assert(c.x == 1)
assert(c.y == 0)
assert(c.z == 0x33/0xFF)
assert(c.w == 1)
if verbose then
  print(tostring(c))
end
assert(tostring(c) == "#F03")
