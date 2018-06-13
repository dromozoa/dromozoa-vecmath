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
  private static String s(Tuple2d t) {
    return "{" + t.x + "," + t.y + "}";
  }

  private static String s(Tuple3d t) {
    return "{" + t.x + "," + t.y + "," + t.z + "}";
  }

  private static String s(Tuple4d t) {
    return "{" + t.x + "," + t.y + "," + t.z + "," + t.w + "}";
  }

  private static String s(AxisAngle4d a) {
    return "{" + a.x + "," + a.y + "," + a.z + "," + a.angle + "}";
  }

  private static String s(Matrix3d m) {
    return "{"
        + m.m00 + "," + m.m01 + "," + m.m02 + ","
        + m.m10 + "," + m.m11 + "," + m.m12 + ","
        + m.m20 + "," + m.m21 + "," + m.m22 + "}";
  }

  private static String s(Matrix4d m) {
    return "{"
        + m.m00 + "," + m.m01 + "," + m.m02 + "," + m.m03 + ","
        + m.m10 + "," + m.m11 + "," + m.m12 + "," + m.m13 + ","
        + m.m20 + "," + m.m21 + "," + m.m22 + "," + m.m23 + ","
        + m.m30 + "," + m.m31 + "," + m.m32 + "," + m.m33 + "}";
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

    m.set(m1);
    m.setScale(2);
    System.out.println("  set_scale2 = " + s(m) + ";");

    System.out.println("  get_scale = " + m1.getScale() + ";");

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

  private static void point2d() {
    Point2d p1 = new Point2d(1, 2);
    Point2d p2 = new Point2d(-3, 4);

    System.out.println("  point2 = {");
    System.out.println("    " + s(p1) + ";");
    System.out.println("    " + s(p2) + ";");
    System.out.println("    distance_squared = " + p1.distanceSquared(p2) + ";");
    System.out.println("    distance = " + p1.distance(p2) + ";");
    System.out.println("    distance_l1 = " + p1.distanceL1(p2) + ";");
    System.out.println("    distance_linf = " + p1.distanceLinf(p2) + ";");
    System.out.println("  };");
  }

  private static void point3d() {
    Point3d p1 = new Point3d(1, 2, 3);
    Point3d p2 = new Point3d(-4, 5, -6);
    Point4d p3 = new Point4d(7, -8, 9, -10);
    Point3d p4 = new Point3d();
    p4.project(p3);

    System.out.println("  point3 = {");
    System.out.println("    " + s(p1) + ";");
    System.out.println("    " + s(p2) + ";");
    System.out.println("    " + s(p3) + ";");
    System.out.println("    distance_squared = " + p1.distanceSquared(p2) + ";");
    System.out.println("    distance = " + p1.distance(p2) + ";");
    System.out.println("    distance_l1 = " + p1.distanceL1(p2) + ";");
    System.out.println("    distance_linf = " + p1.distanceLinf(p2) + ";");
    System.out.println("    project = " + s(p4) + ";");
    System.out.println("  };");
  }

  private static void point4d() {
    Point4d p1 = new Point4d(1, 2, 3, 4);
    Point4d p2 = new Point4d(-5, 6, -7, 8);
    Point4d p3 = new Point4d();
    p3.project(p1);

    System.out.println("  point4 = {");
    System.out.println("    " + s(p1) + ";");
    System.out.println("    " + s(p2) + ";");
    System.out.println("    distance_squared = " + p1.distanceSquared(p2) + ";");
    System.out.println("    distance = " + p1.distance(p2) + ";");
    System.out.println("    distance_l1 = " + p1.distanceL1(p2) + ";");
    System.out.println("    distance_linf = " + p1.distanceLinf(p2) + ";");
    System.out.println("    project = " + s(p3) + ";");
    System.out.println("  };");
  }

  private static void point() {
    System.out.println("return {");
    point2d();
    point3d();
    point4d();
    System.out.println("}");
  }

  private static void vector2d() {
    Vector2d v1 = new Vector2d(1, 2);
    Vector2d v2 = new Vector2d(-3, 4);
    Vector2d v3 = new Vector2d(v1);
    v3.normalize();

    System.out.println("  vector2 = {");
    System.out.println("    " + s(v1) + ";");
    System.out.println("    " + s(v2) + ";");
    System.out.println("    dot = " + v1.dot(v2) + ";");
    System.out.println("    length = " + v1.length() + ";");
    System.out.println("    length_squared = " + v1.lengthSquared() + ";");
    System.out.println("    normalize = " + s(v3) + ";");
    System.out.println("    angle = " + v1.angle(v2) + ";");
    System.out.println("  };");
  }

  private static void vector3d() {
    Vector3d v1 = new Vector3d(1, 2, 3);
    Vector3d v2 = new Vector3d(-4, 5, -6);
    Vector3d v3 = new Vector3d();
    Vector3d v4 = new Vector3d();
    v3.cross(v1, v2);
    v4.normalize(v1);

    System.out.println("  vector3 = {");
    System.out.println("    " + s(v1) + ";");
    System.out.println("    " + s(v2) + ";");
    System.out.println("    cross = " + s(v3) + ";");
    System.out.println("    normalize = " + s(v4) + ";");
    System.out.println("    dot = " + v1.dot(v2) + ";");
    System.out.println("    length_squared = " + v1.lengthSquared() + ";");
    System.out.println("    length = " + v1.length() + ";");
    System.out.println("    angle = " + v1.angle(v2) + ";");
    System.out.println("  };");
  }

  private static void vector4d() {
    Vector4d v1 = new Vector4d(1, 2, 3, 4);
    Vector4d v2 = new Vector4d(-5, 6, -7, 8);
    Vector4d v3 = new Vector4d();
    v3.normalize(v1);

    System.out.println("  vector4 = {");
    System.out.println("    " + s(v1) + ";");
    System.out.println("    " + s(v2) + ";");
    System.out.println("    length = " + v1.length() + ";");
    System.out.println("    length_squared = " + v1.lengthSquared() + ";");
    System.out.println("    dot = " + v1.dot(v2) + ";");
    System.out.println("    normalize = " + s(v3) + ";");
    System.out.println("    angle = " + v1.angle(v2) + ";");
    System.out.println("  };");
  }

  private static void vector() {
    System.out.println("return {");
    vector2d();
    vector3d();
    vector4d();
    System.out.println("}");
  }

  private static void rotation1() {
    Quat4d q = new Quat4d(1, 2, 3, Math.PI / 3);
    AxisAngle4d a = new AxisAngle4d();
    Matrix3d m3 = new Matrix3d();
    Matrix4d m4 = new Matrix4d();
    a.set(q);
    m3.set(q);
    m4.set(q);

    System.out.println("  {");
    System.out.println("    quat4 = " + s(q) + ";");
    System.out.println("    axis_angle4 = " + s(a) + ";");
    System.out.println("    matrix3 = " + s(m3) + ";");
    System.out.println("    matrix4 = " + s(m4) + ";");
    System.out.println("  };");
  }

  private static void rotation2() {
    Quat4d q1 = new Quat4d(1, 2, 3, Math.PI / 6);
    Quat4d q2 = new Quat4d(3, 2, 1, Math.PI / 8);
    Quat4d q = new Quat4d();

    q2.scale(-1);

    System.out.println("  {");
    System.out.println("    q1 = " + s(q1) + ";");
    System.out.println("    q2 = " + s(q2) + ";");
    for (int i = 0; i <= 16; ++i) {
      q.interpolate(q1, q2, i / 16.0);
      System.out.println("    " + s(q) + ";");
    }
    System.out.println("  };");
  }

  private static void rotation() {
    System.out.println("return {");
    rotation1();
    rotation2();
    System.out.println("}");
  }

  public static void main(String[] args) {
    String name = args[0];
    if (name.equals("matrix3d")) {
      matrix3d();
    } else if (name.equals("point")) {
      point();
    } else if (name.equals("vector")) {
      vector();
    } else if (name.equals("rotation")) {
      rotation();
    }
  }
}
