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

local function subdivide(p1, p2, p3, p4, t)
  local v1 = vecmath.vector2(p3):sub(p1):scale(0.5)
  local v2 = vecmath.vector2(p4):sub(p2):scale(0.5)
  local t2 = t * t
  local u = 1 - t
  local u2 = u * u
  local a = (2 * t + 1) * u2
  local b = t * u2
  local c = -t2 * u
  local d = t2 * (3 - 2 * t)
  local p = vecmath.point2()
  p:scale_add(a, p2, p)
  p:scale_add(b, v1, p)
  p:scale_add(c, v2, p)
  p:scale_add(d, p3, p)
  return p
end

local function bezier(p1, p2, p3, p4)
  local v1 = vecmath.vector2(p3):sub(p1):scale(1/6)
  local v2 = vecmath.vector2(p4):sub(p2):scale(1/6)
  local q1 = vecmath.point2(p2):add(v1)
  local q2 = vecmath.point2(p3):sub(v2)
  return q1, q2
end

local N = 4

local points = {}
for i = 1, #arg, 2 do
  points[#points + 1] = vecmath.point2(tonumber(arg[i]), tonumber(arg[i + 1]))
end

io.write [[
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
<title>dromozoa-vecmath</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/2.10.0/github-markdown.min.css">
<style>
.markdown-body {
  box-sizing: border-box;
  min-width: 200px;
  max-width: 980px;
  margin: 0 auto;
  padding: 45px;
}
@media (max-width: 767px) {
  .markdown-body {
    padding: 15px;
  }
}
</style>
</head>
<body>
<div class="markdown-body">

<h1>dromozoa-vecmath</h1>

<svg width="640" height="640">
<g transform="translate(320 320)">
]]

local p = points[1]
io.write(([[
<path d="
M %.17g %.17g L
]]):format(p.x, p.y))
for i = 2, #points do
  p = points[i]
  io.write(("%.17g %.17g\n"):format(p.x, p.y))
end
io.write [[
" fill="none" stroke="#AAA"/>
]]

io.write [[
<path d="
]]
for i = 2, #points - 2 do
  local p1 = points[i - 1]
  local p2 = points[i]
  local p3 = points[i + 1]
  local p4 = points[i + 2]

  io.write(("M %.17g %.17g L\n"):format(p2.x, p2.y))

  for j = 1, N do
    local p = subdivide(p1, p2, p3, p4, j / N)
    io.write(("%.17g %.17g\n"):format(p.x, p.y))
  end
end
io.write [[
" fill="none" stroke="#000"/>
]]

io.write [[
<path d="
]]
for i = 2, #points - 2 do
  local p1 = points[i - 1]
  local p2 = points[i]
  local p3 = points[i + 1]
  local p4 = points[i + 2]

  io.write(("M %.17g %.17g\n"):format(p2.x, p2.y))
  local q1, q2 = bezier(p1, p2, p3, p4)
  io.write(("C %.17g %.17g %.17g %.17g %.17g %.17g\n"):format(q1.x, q1.y, q2.x, q2.y, p3.x, p3.y))
end
io.write [[
" fill="none" stroke="#F00"/>
]]

io.write [[
</g>
</svg>

</div>
<script type="text/x-mathjax-config">
MathJax.Hub.Config({
  CommonHTML: {
    undefinedFamily: "sans-serif"
  }
});
</script>
<script type="text/javascript" async src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=TeX-AMS_CHTML"></script>
</body>
</html>
]]

