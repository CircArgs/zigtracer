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

const printProgressBar = @import("utils.zig").printProgressBar;

const IMAGE_FILE = "image.ppm";
const ASPECT_RATIO: comptime_float = 16.0 / 9.0;
const IMG_HEIGHT: comptime_int = 100;
const IMG_WIDTH: comptime_int = @floor(IMG_HEIGHT * ASPECT_RATIO);
const IMG_ASPECT: comptime_float = @as(comptime_float, @floatFromInt(IMG_WIDTH)) / @as(comptime_float, @floatFromInt(IMG_HEIGHT));
const VIEWPORT_HEIGHT: comptime_float = 2.0;
const VIEWPORT_WIDTH: comptime_float = VIEWPORT_HEIGHT * IMG_ASPECT;
const FOCAL_LENGTH: comptime_float = 1.0;
const CAMERA_CENTER = Point3.init(0, 0, 0);
const VIEWPORT_U = Vec3.init(VIEWPORT_WIDTH, 0, 0);
const VIEWPORT_V = Vec3.init(0, -VIEWPORT_HEIGHT, 0);
const PIXEL_DELTA_U = VIEWPORT_U.scalarDivide(IMG_WIDTH);
const PIXEL_DELTA_V = VIEWPORT_V.scalarDivide(IMG_HEIGHT);
const CAMERA_DIRECTION = VIEWPORT_U.cross(&VIEWPORT_V).normalize().scalarMultiply(FOCAL_LENGTH);
const VIEWPORT_UL = CAMERA_CENTER.add(&CAMERA_DIRECTION).subtract(&VIEWPORT_V.scalarMultiply(0.5)).subtract(&VIEWPORT_U.scalarMultiply(0.5));
// const VIEWPORT_UL = CAMERA_CENTER.subtract(&Vec3.init(0, 0, FOCAL_LENGTH)).subtract(&VIEWPORT_U.scalarDivide(2)).subtract(&VIEWPORT_V.scalarDivide(2));
const PIXEL_ORIGIN = VIEWPORT_UL.add(&PIXEL_DELTA_V.add(&PIXEL_DELTA_U).scalarMultiply(0.5));

fn rayColor(r: *const Ray, world: *const HittableList) color.Color {
    var interval = Interval.default();
    const hit = world.hit(r, &interval);
    if (hit != null) {
        return (hit.?).normal.add(&Vec3.init(1, 1, 1)).scalarDivide(2);
    }

    const unit_direction = r.direction.normalize();
    const a = 0.5 * (unit_direction.getY() + 1);
    return (color.Color.init(1.0, 1.0, 1.0).scalarMultiply(1.0 - a)).add(&color.Color.init(0.5, 0.7, 1.0).scalarMultiply(a));
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var file = try std.fs.cwd().createFile(IMAGE_FILE, std.fs.File.CreateFlags{ .read = true });
    defer file.close();
    try file.writer().print("P3\n{} {}\n255\n", .{ IMG_WIDTH, IMG_HEIGHT });
    var progress: f32 = 0;
    const total_pixels = IMG_WIDTH * IMG_HEIGHT;

    var world = HittableList.init(allocator);
    defer world.deinit();
    try world.add(Hittable.sphere(Point3.init(0, 0, -1), 0.5));
    try world.add(Hittable.sphere(Point3.init(0, -100.5, -1), 100));

    for (0..IMG_HEIGHT) |j| {
        try printProgressBar(@intFromFloat(progress / total_pixels));
        for (0..IMG_WIDTH) |i| {
            const pixel_loc = PIXEL_ORIGIN.add(&PIXEL_DELTA_V.scalarMultiply(@as(f32, @floatFromInt(j))).add(&PIXEL_DELTA_U.scalarMultiply(@as(f32, @floatFromInt(i)))));
            const ray_direction = pixel_loc.subtract(&CAMERA_CENTER);
            const pixel_color = rayColor(&Ray.init(CAMERA_CENTER, ray_direction), &world);
            try color.writeColor(&file, &pixel_color);

            progress += 100;
        }
    }
}
