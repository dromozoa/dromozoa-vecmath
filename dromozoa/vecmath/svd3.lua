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

local epsilon = 1e-9

return function (a, b)
  local a11 = a[1] local a12 = a[2] local a13 = a[3]
  local a21 = a[4] local a22 = a[5] local a23 = a[6]
  local a31 = a[7] local a32 = a[8] local a33 = a[9]

  local a = {
    a11 * a11 + a12 * a12 + a13 * a13;
    a11 * a21 + a12 * a22 + a13 * a23;
    a11 * a31 + a12 * a32 + a13 * a33;

    a21 * a11 + a22 * a12 + a23 * a13;
    a21 * a21 + a22 * a22 + a23 * a23;
    a21 * a31 + a22 * a32 + a23 * a33;

    a31 * a11 + a32 * a12 + a33 * a13;
    a31 * a21 + a32 * a22 + a33 * a23;
    a31 * a31 + a32 * a32 + a33 * a33;
  }

  local count = 0

  while true do
    local p = 1
    local q = 2
    local v = a[2] v = v * v
    local m = v
    local u = a[3] u = u * u m = m + u if v < u then p = 1 q = 3 v = u end
    local u = a[4] u = u * u m = m + u if v < u then p = 2 q = 1 v = u end
    local u = a[6] u = u * u m = m + u if v < u then p = 2 q = 3 v = u end
    local u = a[7] u = u * u m = m + u if v < u then p = 3 q = 1 v = u end
    local u = a[8] u = u * u m = m + u if v < u then p = 3 q = 2 v = u end

    local n = m
    local u = a[1] n = n + u * u
    local u = a[5] n = n + u * u
    local u = a[9] n = n + u * u
    if m / n <= epsilon then
      break
    end
    count = count + 1
    print("!", count, p, q)

    local i = 6 - p - q

    local pq = p * 3 + q - 3
    local qp = q * 3 + p - 3
    local pp = p * 3 + p - 3
    local qq = q * 3 + q - 3
    local pi = p * 3 + i - 3
    local qi = q * 3 + i - 3
    local ip = i * 3 + p - 3
    local iq = i * 3 + q - 3

    local a_pq = a[pq]
    local a_qp = a[qp]
    local a_pp = a[pp]
    local a_qq = a[qq]
    local a_pi = a[pi]
    local a_qi = a[qi]
    local a_ip = a[ip]
    local a_iq = a[iq]

    local angle
    local x = a_pp - a_qq
    if math.abs(x) < epsilon then
      angle = math.pi * 0.25
    else
      angle = math.atan2(-2 * a_pq, x) * 0.5
    end
    local cos = math.cos(angle)
    local sin = math.sin(angle)

    a[pq] = sin * (cos * a_pp - sin * a_pq) + cos * (cos * a_pq - sin * a_qq)
    a[qp] = a[pq]
    a[pp] = cos * (cos * a_pp - sin * a_pq) - sin * (cos * a_pq - sin * a_qq)
    a[qq] = sin * (sin * a_pp + cos * a_pq) + cos * (sin * a_pq + cos * a_qq)

    a[pi] = cos * a_pi - sin * a_qi
    a[qi] = sin * a_pi + cos * a_qi
    a[ip] = cos * a_ip - sin * a_iq
    a[iq] = sin * a_ip + cos * a_ip
  end

  b[1] = math.sqrt(a[1])
  b[2] = math.sqrt(a[5])
  b[3] = math.sqrt(a[9])
end
