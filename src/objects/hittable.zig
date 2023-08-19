const std = @import("std");

const core = @import("core");
const Sphere = @import("sphere.zig");
const Ray = core.Ray;
const Hit = core.Hit;
const Point3 = core.Point3;
const Interval = core.Interval;

pub const Hittable = union(enum) {
    Sphere: Sphere,

    const Self = @This();

    pub fn hit(self: *const Self, ray: *const Ray, interval: *const Interval) ?Hit {
        return self.Sphere.hit(ray, interval);
        // return switch (self) {
        //     inline else => |case| case.hit(ray, interval),
        // };
    }

    pub fn sphere(center: Point3, radius: f32) Self {
        return Self{ .Sphere = Sphere.init(center, radius) };
    }
};

pub const HittableList = struct {
    const Self = @This();

    list: std.ArrayList(Hittable),

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{ .list = std.ArrayList(Hittable).init(allocator) };
    }
    pub fn deinit(self: *Self) void {
        self.list.deinit();
    }
    pub fn hit(self: *const Self, r: *const Ray, interval: *Interval) ?Hit {
        var hit_: ?Hit = null;
        var temp_hit: ?Hit = null;
        for (self.list.items) |object| {
            temp_hit = object.hit(r, interval);
            if (hit_ == null) {
                hit_ = temp_hit;
            } else {
                if (temp_hit != null) {
                    if (temp_hit.?.t < hit_.?.t) {
                        hit_ = temp_hit;
                        interval.max = hit_.?.t;
                    }
                }
            }
        }
        return hit_;
    }

    pub fn add(self: *Self, object: Hittable) !void {
        try self.list.append(object);
    }
};
