const std = @import("std");
const core = @import("core");
const Ray = core.Ray;
const Hit = core.Hit;
const Point3 = core.Point3;
const Vec3 = core.Vec3;

const Self = @This();
center: Point3,
radius: f32,

pub fn init(center: Point3, radius: f32) Self {
    return Self{ .center = center, .radius = radius };
}

pub fn hit(self: *const Self, r: *const Ray) ?Hit {
    const oc = r.origin.subtract(&self.center);
    const a = r.direction.normSquared();
    const b = 2.0 * r.direction.dot(&oc);
    const c = oc.dot(&oc) - self.radius * self.radius;
    const determinant = b * b - 4.0 * a * c;

    if (determinant < 0.0) {
        return null;
    }
    var t = -b + std.math.sqrt(determinant);
    t /= 2.0 * a;
    const p = r.direction.scalarMultiply(t).add(&r.origin);
    const normal = p.subtract(&self.center);
    return Hit.init(p, normal);
}
