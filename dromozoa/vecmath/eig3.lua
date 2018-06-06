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

return function (a, epsilon)
  while true do
    local v = a[2]
    v = v * v
    local s = v
    local p = 1
    local q = 2

    local u = a[3] ; u = u * u ; s = s + u if v < u then p = 1 ; q = 3 ; v = u end
    local u = a[4] ; u = u * u ; s = s + u if v < u then p = 2 ; q = 1 ; v = u end
    local u = a[6] ; u = u * u ; s = s + u if v < u then p = 2 ; q = 3 ; v = u end
    local u = a[7] ; u = u * u ; s = s + u if v < u then p = 3 ; q = 1 ; v = u end
    local u = a[8] ; u = u * u ; s = s + u if v < u then p = 3 ; q = 2 ; v = u end

    if s < epsilon then
      return
    end

    local i = 6 - p - q

    local pa = p * 3
    local qa = q * 3
    local ia = i * 3
    local pb = p - 3
    local qb = q - 3
    local ib = i - 3

    local pq = pa + qb
    local qp = qa + pb
    local pp = pa + pb
    local qq = qa + qb
    local pi = pa + ib
    local qi = qa + ib
    local ip = ia + pb
    local iq = ia + qb

    local a_pq = a[pq]
    local a_qp = a[qp]
    local a_pp = a[pp]
    local a_qq = a[qq]
    local a_pi = a[pi]
    local a_qi = a[qi]

    local z = (a_qq - a_pp) / (2 * a_pq)
    local t
    if z < 0 then
      t = -1 / (-z + sqrt(1 + z * z))
    else
      t = 1 / (z + sqrt(1 + z * z))
    end
    local c = 1 / sqrt(1 + t * t)
    local s = c * t
    local u = s / (1 + c)

    local t_a_pq = t * a_pq
    local a_pi_ip = a_pi - s * (a_qi + u * a_pi)
    local a_qi_iq = a_qi + s * (a_pi - u * a_qi)

    a[pq] = 0
    a[qp] = 0
    a[pp] = a_pp - t_a_pq
    a[qq] = a_qq + t_a_pq
    a[pi] = a_pi_ip
    a[qi] = a_qi_iq
    a[ip] = a_pi_ip
    a[iq] = a_qi_iq
  end
end
