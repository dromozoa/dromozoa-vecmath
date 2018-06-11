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

-- sqrt(6) * DBL_EPSILON
local epsilon = 5.438959822042066e-16

local function jacobi(m, u, v, pp, pq, pi, qp, qq, qi, ip, iq)
  local m_pp = m[pp] local m_pq = m[pq] local m_pi = m[pi]
  local m_qp = m[qp] local m_qq = m[qq] local m_qi = m[qi]
  local m_ip = m[ip] local m_iq = m[iq]

  if m_qp ~= m_pq then
    local x = m_qp - m_pq
    local y = m_pp + m_qq
    local z = sqrt(x * x + y * y)
    local s = x / z
    local c = y / z
    local h = s / (1 + c)

    m_pp, m_pq = m_pp - (m_pq + m_pp * h) * s, m_pq + (m_pp - m_pq * h) * s
    m_qp, m_qq = m_pq,                         m_qq + (m_qp - m_qq * h) * s
    m_ip, m_iq = m_ip - (m_iq + m_ip * h) * s, m_iq + (m_ip - m_iq * h) * s

    if v then
      local v_pp = v[pp] local v_pq = v[pq]
      local v_qp = v[qp] local v_qq = v[qq]
      local v_ip = v[ip] local v_iq = v[iq]

      v[pp] = v_pp - (v_pq + v_pp * h) * s ; v[pq] = v_pq + (v_pp - v_pq * h) * s
      v[qp] = v_qp - (v_qq + v_qp * h) * s ; v[qq] = v_qq + (v_qp - v_qq * h) * s
      v[ip] = v_ip - (v_iq + v_ip * h) * s ; v[iq] = v_iq + (v_ip - v_iq * h) * s
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

  m[pp] = m_pp - m_pq * t
  m[pq] = 0
  m[pi] = m_pi - (m_qi + m_pi * h) * s
  m[qp] = 0
  m[qq] = m_qq + m_pq * t
  m[qi] = m_qi + (m_pi - m_qi * h) * s
  m[ip] = m_ip - (m_iq + m_ip * h) * s
  m[iq] = m_iq + (m_ip - m_iq * h) * s

  if u then
    local u_pp = u[pp] local u_pq = u[pq]
    local u_qp = u[qp] local u_qq = u[qq]
    local u_ip = u[ip] local u_iq = u[iq]

    u[pp] = u_pp - (u_pq + u_pp * h) * s ; u[pq] = u_pq + (u_pp - u_pq * h) * s
    u[qp] = u_qp - (u_qq + u_qp * h) * s ; u[qq] = u_qq + (u_qp - u_qq * h) * s
    u[ip] = u_ip - (u_iq + u_ip * h) * s ; u[iq] = u_iq + (u_ip - u_iq * h) * s
  end

  if v then
    local v_pp = v[pp] local v_pq = v[pq]
    local v_qp = v[qp] local v_qq = v[qq]
    local v_ip = v[ip] local v_iq = v[iq]

    v[pp] = v_pp - (v_pq + v_pp * h) * s ; v[pq] = v_pq + (v_pp - v_pq * h) * s
    v[qp] = v_qp - (v_qq + v_qp * h) * s ; v[qq] = v_qq + (v_qp - v_qq * h) * s
    v[ip] = v_ip - (v_iq + v_ip * h) * s ; v[iq] = v_iq + (v_ip - v_iq * h) * s
  end
end

return function (a, b, c)
  while true do
    local u = a[2]
    local v = a[4]
    local s = u * u + v * v
    local w = s
    local pq = 12

    local u = a[3]
    local v = a[7]
    u = u * u + v * v
    s = s + u
    if w < u then
      w = u
      pq = 13
    end

    local u = a[6]
    local v = a[8]
    u = u * u + v * v
    s = s + u
    if w < u then
      w = u
      pq = 23
    end

    if s < epsilon then
      break
    end

    if pq == 12 then
      jacobi(a, b, c, 1, 2, 3, 4, 5, 6, 7, 8)
    elseif pq == 13 then
      jacobi(a, b, c, 1, 3, 2, 7, 9, 8, 4, 6)
    else
      jacobi(a, b, c, 5, 6, 4, 8, 9, 7, 2, 3)
    end
  end

  local s1 = a[1]
  local s2 = a[5]
  local s3 = a[9]

  if s1 < 0 then
    s1 = -s1
    a[1] = s1
    a[4] = -a[4]
    a[7] = -a[7]
    if c then
      c[1] = -c[1]
      c[4] = -c[4]
      c[7] = -c[7]
    end
  end

  if s2 < 0 then
    s2 = -s2
    a[2] = -a[2]
    a[5] = s2
    a[8] = -a[8]
    if c then
      c[2] = -c[2]
      c[5] = -c[5]
      c[8] = -c[8]
    end
  end

  if s3 < 0 then
    s3 = -s3
    a[3] = -a[3]
    a[6] = -a[6]
    a[9] = s3
    if c then
      c[3] = -c[3]
      c[6] = -c[6]
      c[9] = -c[9]
    end
  end

  if s1 > s2 then
    if s1 > s3 then
      return s1
    else
      return s3
    end
  else
    if s2 > s3 then
      return s2
    else
      return s3
    end
  end
end
