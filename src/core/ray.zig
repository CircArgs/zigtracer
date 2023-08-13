const Vec3 = @import("vec3.zig");

const Self = @This();

pub const Point3 = Vec3;

origin: Point3,
direction: Vec3,

pub fn init(origin: Point3, direction: Vec3) Self {
    return Self{ .origin = origin, .direction = direction };
}

pub fn at(self: *const Self, t: f32) Point3 {
    return self.origin.add(self.direction.scalarMultiply(t));
}

const std = @import("std");
test "test ray" {
    const origin = Point3.init(0, 0, 0);
    const direction = Vec3.init(1, 2, 3);
    const ray = Self.init(origin, direction);

    // Check the values of the ray
    try std.testing.expectEqual(ray.origin, origin);
    try std.testing.expectEqual(ray.direction, direction);

    // Test the 'at' function
    const t = 2.5;
    const expectedPoint = origin.add(direction.scalarMultiply(t));
    const actualPoint = ray.at(t);
    try std.testing.expectEqual(actualPoint, expectedPoint);
}
