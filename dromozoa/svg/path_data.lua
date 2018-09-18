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

local lineto = require "dromozoa.svg.lineto"
local moveto = require "dromozoa.svg.moveto"

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

function class:L(...)
  self[#self + 1] = lineto(...)
  return self
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
