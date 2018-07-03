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
local matrix2 = vecmath.matrix2
local curve = vecmath.curve

local n = 16

local function draw_cubic_bezier(node, P)
  local p1, p2, p3, p4 = unpack(P)

  local d = path_data()
  d:M(p1.x, p1.y):C(p2.x, p2.y, p3.x, p3.y, p4.x, p4.y)

  node[#node + 1] = _"path" {
    d = d;
    fill = "none";
    stroke = "#333";
  }

  local m = matrix2(p1.y - p2.y, p4.y - p3.y, p2.x - p1.x, p3.x - p4.x)
  local c = { math.huge, math.huge }
  if m:determinant() ~= 0 then
    c = m:invert():transform(point2(p4.x - p1.x, p4.y - p1.y)):scale(1/3)
  end

  local F = { point2(), point2(), point2(), point2() }
  curve.to_cubic_bezier(function (t, q)
    curve.diff_cubic_bezier(P, t, q)
    q.x, q.y = -q.y, q.x
    q:scale(c[1] * (1 - t) + c[2] * t)
    q:add(curve.cubic_bezier(P, t, point2()))
    return q
  end, F)

  node[#node + 1] = _"path" {
    d = path_data():M(F[1].x, F[1].y):C(F[2].x, F[2].y, F[3].x, F[3].y, F[4].x, F[4].y);
    fill = "none";
    stroke = "#333";
  }

  local d = path_data()
  for i = 0, n do
    local t = i / n
    local p = curve.cubic_bezier(P, t, point2())
    local f = curve.cubic_bezier(F, t, point2())
    d:M(p.x, p.y):L(f.x, f.y)
  end

  node[#node + 1] = _"path" {
    d = d;
    fill = "none";
    stroke = "#F33";
    ["stroke-opacity"] = 0.5;
  }

  return F
end

local function draw_td(node, P, F)
  local p1, p2, p3, p4 = unpack(P)

  node[#node + 1] = _"path" {
    d = path_data():M(0, 0):H(640);
    fill = "none";
    stroke = "#CCC";
  }

  local x = 640
  local y = 1/640

  for j = 0, 3 do
    local u = j / 3
    local d = path_data()

    local Q = { point2(), point2(), point2(), point2(), point2(), point2() }
    curve.to_quintic_bezier(function (t, q)
      local a = curve.diff_cubic_bezier(P, t, vector2())
      local b = curve.cubic_bezier(P, t, vector2()):sub(curve.cubic_bezier(F, u, vector2()))
      return q:set(t, a:dot(b))
    end, Q)

    local d = path_data()
    d:M(Q[1].x * x, Q[1].y * y)
    for i = 2, 6 do
      d:L(Q[i].x * x, Q[i].y * y)
    end

    node[#node + 1] = _"path" {
      d = d;
      fill = "none";
      stroke = "#F33";
      ["stroke-opacity"] = 0.5;
    }
  end
end

local P = {
  point2(-100, -100);
  point2( -50,    0);
  point2(  50,    0);
  point2( 100, -100);
}

local Q = {
  point2(-50, -100);
  point2(  0,    0);
  point2(100,    0);
  point2(250, -100);
}

local F = point2(100, -50)

local root = _"g" {
  transform = "translate(320, 320)";
}

local td_root = _"g" {
  transform = "translate(640, 320)";
}

local Fp = draw_cubic_bezier(root, P)
local Fq = draw_cubic_bezier(root, Q)
-- draw_td(td_root, P, Fq)
draw_td(td_root, Q, Fp)

-- root[#root + 1] = _"circle" {
--   cx = F.x;
--   cy = F.y;
--   r = 2;
-- }
-- draw_td_p(td_root, P, F)

local svg = _"svg" {
  xmlns = "http://www.w3.org/2000/svg";
  ["xmlns:xlink"] ="http://www.w3.org/1999/xlink";
  version = "1.1";
  width = 1280;
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
    width = 640;
    height = 640;
    fill = "none";
    stroke = "#CCC";
  };
  root;
  td_root;
}

local doc = xml_document(svg)
local out = assert(io.open("test.svg", "w"))
doc:serialize(out)
out:write "\n"
out:close()
