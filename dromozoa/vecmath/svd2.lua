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

local sqrt = math.sqrt

return function (m, u, v)
  -- p,q = 1,2
  local m_pp = m[1]
  local m_pq = m[2]
  local m_qp = m[3]
  local m_qq = m[4]

  if m_qp ~= m_pq then
    local x = m_qp - m_pq
    local y = m_pp + m_qq
    local z = sqrt(x * x + y * y)
    local s = x / z
    local c = y / z
    local h = s / (1 + c)

    m_pp, m_pq = m_pp - (m_pq + m_pp * h) * s, m_pq + (m_pp - m_pq * h) * s
    m_qq = m_qq + (m_qp - m_qq * h) * s
    m_qp = m_pq

    if v then
      local v_pp = v[1]
      local v_pq = v[2]
      local v_qp = v[3]
      local v_qq = v[4]
      v[1] = v_pp - (v_pq + v_pp * h) * s
      v[2] = v_pq + (v_pp - v_pq * h) * s
      v[3] = v_qp - (v_qq + v_qp * h) * s
      v[4] = v_qq + (v_qp - v_qq * h) * s
    end
  end

  local x = (m_qq - m_pp) * 0.5 / m_pq
  local t
  if x < 0 then
    t = 1 / (x - sqrt(1 + x * x))
  else
    t = 1 / (x + sqrt(1 + x * x))
  end
  local c = 1 / sqrt(1 + t * t)
  local s = c * t
  local h = s / (1 + c)

  m[1] = m_pp - m_pq * t
  m[2] = 0
  m[3] = 0
  m[4] = m_qq + m_pq * t

  if u then
    local u_pp = u[1]
    local u_pq = u[2]
    local u_qp = u[3]
    local u_qq = u[4]
    u[1] = u_pp - (u_pq + u_pp * h) * s
    u[2] = u_pq + (u_pp - u_pq * h) * s
    u[3] = u_qp - (u_qq + u_qp * h) * s
    u[4] = u_qq + (u_qp - u_qq * h) * s
  end

  if v then
    local v_pp = v[1]
    local v_pq = v[2]
    local v_qp = v[3]
    local v_qq = v[4]
    v[1] = v_pp - (v_pq + v_pp * h) * s
    v[2] = v_pq + (v_pp - v_pq * h) * s
    v[3] = v_qp - (v_qq + v_qp * h) * s
    v[4] = v_qq + (v_qp - v_qq * h) * s
  end

  local sx = m[1]
  local sy = m[4]

  if sx < 0 then
    sx = -sx
    m[1] = sx
    m[3] = -m[3]
    if v then
      v[1] = -v[1]
      v[3] = -v[3]
    end
  end

  if sy < 0 then
    sy = -sy
    m[2] = -m[2]
    m[4] = sy
    if v then
      v[2] = -v[2]
      v[4] = -v[4]
    end
  end

  if sx > sy then
    return sx, sy
  else
    m[1] = sy
    m[4] = sx
    m[2], m[3] = -m[3], -m[2]
    if u then
      u[1], u[2] = -u[2], u[1]
      u[3], u[4] = -u[4], u[3]
    end
    if v then
      v[1], v[2] = -v[2], v[1]
      v[3], v[4] = -v[4], v[3]
    end
    return sy, sx
  end
end
