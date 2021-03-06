#! /bin/sh -e

# Copyright (C) 2018 Tomoyuki Fujimori <moyu@dromozoa.com>
#
# This file is part of dromozoa-vecmath.
#
# dromozoa-vecmath is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# dromozoa-vecmath is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with dromozoa-vecmath.  If not, see <http://www.gnu.org/licenses/>.

CLASSPATH=lib/vecmath.jar:target/classes
export CLASSPATH

java com.dromozoa.vecmath.Application matrix3 >../matrix3.lua
java com.dromozoa.vecmath.Application matrix4 >../matrix4.lua
java com.dromozoa.vecmath.Application point >../point.lua
java com.dromozoa.vecmath.Application vector >../vector.lua
java com.dromozoa.vecmath.Application quat >../quat.lua
java com.dromozoa.vecmath.Application rotation >../rotation.lua
