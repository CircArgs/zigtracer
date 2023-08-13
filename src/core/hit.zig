const Ray = @import("ray.zig");
const Point3 = Ray.Point3;
const Vec3 = @import("vec3.zig");

p: Point3,
normal: Vec3,

const Self = @This();

pub fn init(p: Point3, normal: Vec3) Self {
    return Self{ .p = p, .normal = normal };
}
