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

public class Application {
  private static String s(Tuple3d t) {
    return "{" + t.x + "," + t.y + "," + t.z + "}";
  }

  private static String s(Matrix3d m) {
    return "{"
        + m.m00 + "," + m.m01 + "," + m.m02 + ","
        + m.m10 + "," + m.m11 + "," + m.m12 + ","
        + m.m20 + "," + m.m21 + "," + m.m22 + "}";
  }

  private static void matrix3d() {
    Matrix3d m = new Matrix3d();
    Vector3d v = new Vector3d();

    Matrix3d m1 = new Matrix3d(2, 1, 4, 1, -2, 3, -3, -1, 1);
    Matrix3d m2 = new Matrix3d(1, 2, 1, 2, 1, 0, 1, 1, 2);
    Vector3d v1 = new Vector3d(1, 2, 3);

    System.out.println("return {");
    System.out.println("  " + s(m1) + ";");
    System.out.println("  " + s(m2) + ";");
    System.out.println("  " + s(v1) + ";");

    System.out.println("  get_scale = " + m1.getScale() + ";");

    m.set(m1);
    m.setScale(2);
    System.out.println("  set_scale2 = " + s(m) + ";");

    m.add(2, m1);
    System.out.println("  add2 = " + s(m) + ";");

    m.add(m1, m2);
    System.out.println("  add = " + s(m) + ";");

    m.sub(m1, m2);
    System.out.println("  sub = " + s(m) + ";");

    m.transpose(m1);
    System.out.println("  transpose = " + s(m) + ";");

    m.invert(m1);
    System.out.println("  invert = " + s(m) + ";");

    System.out.println("  determinant = " + m1.determinant() + ";");

    m.rotX(2);
    System.out.println("  rot_x2 = " + s(m) + ";");

    m.rotY(2);
    System.out.println("  rot_y2 = " + s(m) + ";");

    m.rotZ(2);
    System.out.println("  rot_z2 = " + s(m) + ";");

    m.mul(2, m1);
    System.out.println("  mul2 = " + s(m) + ";");

    m.mul(m1, m2);
    System.out.println("  mul = " + s(m) + ";");

    m.mulNormalize(m1, m2);
    System.out.println("  mul_normalize = " + s(m) + ";");

    m.mulTransposeBoth(m1, m2);
    System.out.println("  mul_transpose_both = " + s(m) + ";");

    m.mulTransposeRight(m1, m2);
    System.out.println("  mul_transpose_right = " + s(m) + ";");

    m.mulTransposeLeft(m1, m2);
    System.out.println("  mul_transpose_left = " + s(m) + ";");

    m.normalize(m1);
    System.out.println("  normalize = " + s(m) + ";");

    m.normalizeCP(m1);
    System.out.println("  normalize_cp = " + s(m) + ";");

    m.negate(m1);
    System.out.println("  negate = " + s(m) + ";");

    m.set(m1);
    m.transform(v1, v);
    System.out.println("  transform = " + s(v) + ";");

    System.out.println("}");
  }

  public static void main(String[] args) {
    String name = "matrix3d";
    if (name.equals("matrix3d")) {
      matrix3d();
    }
  }
}
