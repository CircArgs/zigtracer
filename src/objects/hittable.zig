const std = @import("std");

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

pub const HittableList = struct {
    const Self = @This();

    list: std.ArrayList(Hittable),

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{ .list = std.ArrayList(Hittable).init(allocator) };
    }
    pub fn deinit(self: *Self) void {
        self.list.deinit();
    }
    pub fn hit(self: *const Self, r: *const Ray, t_min: f32, t_max: f32) ?Hit {
        var hit_: ?Hit = null;
        var temp_hit: ?Hit = null;
        for (self.list.items) |object| {
            temp_hit = object.hit(r, t_min, t_max);
            if (hit_ == null) {
                hit_ = temp_hit;
            } else {
                if (temp_hit != null) {
                    if (temp_hit.?.t < hit_.?.t) {
                        hit_ = temp_hit;
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
