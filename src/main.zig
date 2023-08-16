const std = @import("std");
const core = @import("core");
const Ray = core.Ray;
const Hit = core.Hit;
const Point3 = core.Point3;
const Vec3 = core.Vec3;
const color = core.color;
const objects = @import("objects");
const Hittable = objects.Hittable;
const Sphere = objects.Sphere;
const HittableList = objects.HittableList;
const Interval = core.Interval;
const Camera = @import("camera.zig");

const printProgressBar = @import("utils.zig").printProgressBar;

const IMAGE_FILE = "image.ppm";
const ASPECT_RATIO: comptime_float = 16.0 / 9.0;
const IMG_HEIGHT: comptime_int = 100;
const IMG_WIDTH: comptime_int = @floor(IMG_HEIGHT * ASPECT_RATIO);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var file = try std.fs.cwd().createFile(IMAGE_FILE, std.fs.File.CreateFlags{ .read = true });
    defer file.close();
    try file.writer().print("P3\n{} {}\n255\n", .{ IMG_WIDTH, IMG_HEIGHT });

    var world = HittableList.init(allocator);
    defer world.deinit();
    try world.add(Hittable.sphere(Point3.init(0, 0, -1), 0.5));
    try world.add(Hittable.sphere(Point3.init(0, -100.5, -1), 100));
    const camera = Camera.init(ASPECT_RATIO, IMG_WIDTH);
    camera.render(&world, &file);
}
