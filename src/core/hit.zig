const Ray = @import("ray.zig");
const Point3 = Ray.Point3;
const Vec3 = @import("vec3.zig");

p: Point3,
normal: Vec3,
t: f32,

const Self = @This();

pub fn init(p: Point3, normal: Vec3, t: f32) Self {
    return Self{ .p = p, .normal = normal, .t = t };
}
