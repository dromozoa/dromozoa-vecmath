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

local arcto = require "dromozoa.svg.arcto"
local close_path = require "dromozoa.svg.close_path"
local cubic_curveto = require "dromozoa.svg.cubic_curveto"
local lineto = require "dromozoa.svg.lineto"
local moveto = require "dromozoa.svg.moveto"
local quadratic_curveto = require "dromozoa.svg.quadratic_curveto"

local setmetatable = setmetatable
local tostring = tostring
local concat = table.concat

local class = { is_path_data = true }
local metatable = {
  __index = class;
  ["dromozoa.dom.is_serializable"] = true;
}

function class:M(...)
  self[#self + 1] = moveto(...)
  return self
end

function class:Z()
  self[#self + 1] = close_path()
  return self
end

function class:L(...)
  self[#self + 1] = lineto(...)
  return self
end

function class:C(...)
  self[#self + 1] = cubic_curveto(...)
  return self
end

function class:Q(...)
  self[#self + 1] = quadratic_curveto(...)
  return self
end

function class:A(...)
  self[#self + 1] = arcto(...)
  return self
end

function class:bezier(result)
  for i = 1, #result do
    result[i] = nil
  end
  local s
  local q
  for i = 1, #self do
    local segment = self[i]
    if segment.is_moveto then
      s = segment[1]
      q = s
    else
      q = segment:bezier(s, q, result)
    end
  end
  return result
end

function metatable:__tostring()
  local buffer = {}
  for i = 1, #self do
    buffer[i] = tostring(self[i])
  end
  return concat(buffer, " ")
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({}, metatable)
  end;
})
