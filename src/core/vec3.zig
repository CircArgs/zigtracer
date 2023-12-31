//! This module provides a struct representing a three dimentional vector.

const Self = @This();

const std = @import("std");

vals: @Vector(3, f32),

/// Returns a `Vec3` struct from 3 arguments representing
/// (x, y, z)
pub fn init(x: f32, y: f32, z: f32) Self {
    return Self{
        .vals = .{ x, y, z },
    };
}

/// Returns the `x` value of a `Vec3`
pub fn getX(self: *const Self) f32 {
    return self.vals[0];
}

/// Returns the `y` value of a `Vec3`
pub fn getY(self: *const Self) f32 {
    return self.vals[1];
}

/// Returns the `z` value of a `Vec3`
pub fn getZ(self: *const Self) f32 {
    return self.vals[2];
}

/// Returns the result of multiplying a `Vec3` by a scalar
pub fn scalarMultiply(self: *const Self, scalar: f32) Self {
    return Self{ .vals = self.vals * @Vector(3, f32){ scalar, scalar, scalar } };
}

/// Returns the result of dividing a `Vec3` by a scalar
pub fn scalarDivide(self: *const Self, scalar: f32) Self {
    return Self{ .vals = self.vals / @Vector(3, f32){ scalar, scalar, scalar } };
}

/// Returns the result of adding two `Vec3`s
pub fn add(self: *const Self, other: *const Self) Self {
    return Self{ .vals = self.vals + other.vals };
}

/// Returns the result of subtracting two `Vec3`s
pub fn subtract(self: *const Self, other: *const Self) Self {
    return Self{ .vals = self.vals - other.vals };
}

/// Returns the result of multiplying two `Vec3`s
pub fn multiply(self: *const Self, other: *const Self) Self {
    return Self{ .vals = self.vals * other.vals };
}

/// Returns the dot product of two `Vec3`s
pub fn dot(self: *const Self, other: *const Self) f32 {
    return self.getX() * other.getX() + self.getY() * other.getY() + self.getZ() * other.getZ();
}

/// Returns the cross product of two `Vec3`s
pub fn cross(self: *const Self, other: *const Self) Self {
    return Self.init(
        self.getY() * other.getZ() - self.getZ() * other.getY(),
        self.getZ() * other.getX() - self.getX() * other.getZ(),
        self.getX() * other.getY() - self.getY() * other.getX(),
    );
}

/// Returns the unit vector of a `Vec3`
pub fn normalize(self: *const Self) Self {
    return self.scalarDivide(self.norm());
}

/// Returns the norm of a `Vec3`
pub fn norm(self: *const Self) f32 {
    return @sqrt(self.normSquared());
}

/// Returns the square of the norm of a `Vec3`
pub fn normSquared(self: *const Self) f32 {
    const new_vec = self.vals * self.vals;
    return @reduce(.Add, new_vec);
}

test "vec3/vec3.accessors" {
    const vec3 = Self.init(1.0, 2.0, 3.0);

    try std.testing.expectEqual(@as(f32, 1.0), vec3.getX());
    try std.testing.expectEqual(@as(f32, 2.0), vec3.getY());
    try std.testing.expectEqual(@as(f32, 3.0), vec3.getZ());
}

test "vec3/vec3.scalarMultiply" {
    const vec3 = Self.init(1.0, 2.0, 3.0);

    try std.testing.expectEqual(Self.init(2.0, 4.0, 6.0), vec3.scalarMultiply(2.0));
    try std.testing.expectEqual(Self.init(1.5, 3.0, 4.5), vec3.scalarMultiply(1.5));
    try std.testing.expectEqual(Self.init(0.5, 1.0, 1.5), vec3.scalarMultiply(0.5));
    try std.testing.expectEqual(Self.init(-2.0, -4.0, -6.0), vec3.scalarMultiply(-2.0));
    try std.testing.expectEqual(Self.init(-1.5, -3.0, -4.5), vec3.scalarMultiply(-1.5));
    try std.testing.expectEqual(Self.init(-0.5, -1.0, -1.5), vec3.scalarMultiply(-0.5));
    try std.testing.expectEqual(Self.init(0.0, 0.0, 0.0), vec3.scalarMultiply(0.0));
}

test "vec3/vec3.scalarDivide" {
    const vec3 = Self.init(1.0, 2.0, 3.0);

    try std.testing.expectEqual(Self.init(1.0 / 2.0, 2.0 / 2.0, 3.0 / 2.0), vec3.scalarDivide(2.0));
    try std.testing.expectEqual(Self.init(1.0 / 1.5, 2.0 / 1.5, 3.0 / 1.5), vec3.scalarDivide(1.5));
    try std.testing.expectEqual(Self.init(1.0 / 0.5, 2.0 / 0.5, 3.0 / 0.5), vec3.scalarDivide(0.5));
    try std.testing.expectEqual(Self.init(-1.0 / 2.0, -2.0 / 2.0, -3.0 / 2.0), vec3.scalarDivide(-2.0));
    try std.testing.expectEqual(Self.init(-1.0 / 1.5, -2.0 / 1.5, -3.0 / 1.5), vec3.scalarDivide(-1.5));
    try std.testing.expectEqual(Self.init(-1.0 / 0.5, -2.0 / 0.5, -3.0 / 0.5), vec3.scalarDivide(-0.5));
}

test "vec3/vec3.add" {
    const vec3 = Self.init(1.0, 2.0, 3.0);
    const vec3_1 = Self.init(1.0, 2.0, 3.0);
    const vec3_2 = Self.init(-3.0, -2.0, -1.0);
    const vec3_3 = Self.init(4.0, -2.0, 1.5);

    try std.testing.expectEqual(Self.init(2.0, 4.0, 6.0), vec3.add(&vec3_1));
    try std.testing.expectEqual(Self.init(-2.0, 0.0, 2.0), vec3.add(&vec3_2));
    try std.testing.expectEqual(Self.init(5.0, 0.0, 4.5), vec3.add(&vec3_3));
    try std.testing.expectEqual(vec3, vec3.add(&Self.init(0.0, 0.0, 0.0)));
}

test "vec3/vec3.subtract" {
    const vec3 = Self.init(1.0, 2.0, 3.0);
    const vec3_1 = Self.init(1.0, 2.0, 3.0);
    const vec3_2 = Self.init(-3.0, -2.0, -1.0);
    const vec3_3 = Self.init(4.0, -2.0, 1.5);

    try std.testing.expectEqual(Self.init(0.0, 0.0, 0.0), vec3.subtract(&vec3_1));
    try std.testing.expectEqual(Self.init(4.0, 4.0, 4.0), vec3.subtract(&vec3_2));
    try std.testing.expectEqual(Self.init(-3.0, 4.0, 1.5), vec3.subtract(&vec3_3));
    try std.testing.expectEqual(vec3, vec3.subtract(&Self.init(0.0, 0.0, 0.0)));
}

test "vec3/vec3.multiply" {
    const vec3 = Self.init(1.0, 2.0, 3.0);
    const vec3_1 = Self.init(1.0, 2.0, 3.0);
    const vec3_2 = Self.init(-3.0, -2.0, -1.0);
    const vec3_3 = Self.init(4.0, -2.0, 1.5);

    try std.testing.expectEqual(Self.init(1.0, 4.0, 9.0), vec3.multiply(&vec3_1));
    try std.testing.expectEqual(Self.init(-3.0, -4.0, -3.0), vec3.multiply(&vec3_2));
    try std.testing.expectEqual(Self.init(4.0, -4.0, 4.5), vec3.multiply(&vec3_3));
    try std.testing.expectEqual(Self.init(0.0, 0.0, 0.0), vec3.multiply(&Self.init(0.0, 0.0, 0.0)));
}

test "vec3/vec3.dot" {
    const vec3 = Self.init(1.0, 2.0, 3.0);
    const vec3_1 = Self.init(1.0, 2.0, 3.0);
    const vec3_2 = Self.init(-3.0, -2.0, -1.0);
    const vec3_3 = Self.init(4.0, -2.0, 1.5);

    try std.testing.expectEqual(@as(f32, 14.0), vec3.dot(&vec3_1));
    try std.testing.expectEqual(@as(f32, -10.0), vec3.dot(&vec3_2));
    try std.testing.expectEqual(@as(f32, 4.5), vec3.dot(&vec3_3));
    try std.testing.expectEqual(@as(f32, 0.0), vec3.dot(&Self.init(0.0, 0.0, 0.0)));
}

test "vec3/vec3.cross" {
    const vec3_1 = Self.init(2.0, 3.0, 4.0);
    const vec3_2 = Self.init(5.0, 6.0, 7.0);
    const vec3_3 = Self.init(3.0, 4.0, 5.0);
    const vec3_4 = Self.init(7.0, 8.0, 9.0);

    try std.testing.expectEqual(Self.init(-3.0, 6.0, -3.0), vec3_1.cross(&vec3_2));
    try std.testing.expectEqual(Self.init(-4.0, 8.0, -4.0), vec3_3.cross(&vec3_4));
    try std.testing.expectEqual(Self.init(0.0, 0.0, 0.0), vec3_1.cross(&Self.init(0.0, 0.0, 0.0)));
}

test "vec3/vec3.normalize" {}

test "vec3/vec3.norm" {
    const vec3_1 = Self.init(2.0, 3.0, 6.0);
    const vec3_2 = Self.init(4.0, 4.0, 7.0);
    const vec3_3 = Self.init(2.0, 2.0, 2.0);

    try std.testing.expectEqual(@as(f32, 49.0), vec3_1.normSquared());
    try std.testing.expectEqual(@as(f32, 7.0), vec3_1.norm());
    try std.testing.expectEqual(@as(f32, 81.0), vec3_2.normSquared());
    try std.testing.expectEqual(@as(f32, 9.0), vec3_2.norm());
    try std.testing.expectEqual(@as(f32, 12.0), vec3_3.normSquared());
    try std.testing.expectEqual(@as(f32, @sqrt(12.0)), vec3_3.norm());
}
