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

pub fn hit(self: *const Self, r: *const Ray, t_min: f32, t_max: f32) ?Hit {
    const oc = r.origin.subtract(&self.center);
    const a = r.direction.normSquared();
    const half_b = r.direction.dot(&oc);
    const c = oc.normSquared() - self.radius * self.radius;

    const discriminant = half_b * half_b - a * c;

    if (discriminant < 0)
        return null;
    const sqrtd = std.math.sqrt(discriminant);

    var t = (-half_b - sqrtd) / a;
    if (t < t_min or t_max < t) {
        t = (-half_b + sqrtd) / a;
        if (t < t_min or t_max < t)
            return null;
    }
    const p = r.direction.scalarMultiply(t).add(&r.origin);
    const normal = p.subtract(&self.center).scalarDivide(self.radius);
    return Hit.init(p, normal, t);
}
