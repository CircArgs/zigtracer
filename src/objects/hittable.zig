const core = @import("core");
const Sphere = @import("sphere.zig");
const Ray = core.Ray;
const Hit = core.Hit;
const Point3 = core.Point3;

pub const Hittable = union(enum) {
    Sphere: Sphere,

    const Self = @This();

    pub fn hit(self: *const Self, ray: *const Ray, t_min: f32, t_max: f32) ?Hit {
        return self.Sphere.hit(ray, t_min, t_max);
        // const std = @import("std");
        // std.debug.print("{}", .{self.Sphere});
        // return switch (@TypeOf(self)) {
        //     Sphere => |s| s.Sphere.hit(ray),
        //     else => null,
        // };
    }

    pub fn sphere(center: Point3, radius: f32) Self {
        return Self{ .Sphere = Sphere.init(center, radius) };
    }
};
