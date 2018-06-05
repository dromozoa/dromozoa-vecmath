// Copyright (C) 2018 Tomoyuki Fujimori <moyu@dromozoa.com>
//
// This file is part of dromozoa-vecmath.
//
// dromozoa-vecmath is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// dromozoa-vecmath is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with dromozoa-vecmath.  If not, see <http://www.gnu.org/licenses/>.

package com.dromozoa.vecmath;

import javax.vecmath.*;
import junit.framework.TestCase;

public class ApplicationTest extends TestCase {
  public void testToString() {
    System.out.println("Matrix3d\n" + new Matrix3d(1, 2, 3, 4, 5, 6, 7, 8, 9));
    System.out.println("Point3d\n" + new Point3d(2, 3, 4));
    System.out.println("Vector3d\n" + new Vector3d(3, 4, 5));
  }

  public void testMatrix3d() {
    String[] args = { "matrix3d" };
    Application.main(args);
  }
}