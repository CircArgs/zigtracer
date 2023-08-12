const std = @import("std");
const Vec3 = @import("vec3.zig");
const color = @import("color.zig");
const ray = @import("ray.zig");
const Point3 = ray.Point3;
const printProgressBar = @import("utils.zig").printProgressBar;

const IMAGE_FILE = "image.ppm";
const ASPECT_RATIO: comptime_float = 16.0 / 9.0;
const IMG_HEIGHT: comptime_int = 100;
const IMG_WIDTH: comptime_int = @floor(IMG_HEIGHT * ASPECT_RATIO);
const IMG_ASPECT: comptime_float = @as(comptime_float, @floatFromInt(IMG_WIDTH)) / @as(comptime_float, @floatFromInt(IMG_HEIGHT));
const VIEWPORT_HEIGHT: comptime_float = 2.0;
const VIEWPORT_WIDTH: comptime_int = @round(VIEWPORT_HEIGHT * IMG_ASPECT);
const FOCAL_LENGTH: comptime_float = 1.0;
const CAMERA_CENTER = Point3(0, 0, 0);
const VIEWPORT_U = Vec3(VIEWPORT_WIDTH, 0, 0);
const VIEWPORT_V = Vec3(0, -VIEWPORT_HEIGHT, 0);
const PIXEL_DELTA_U = VIEWPORT_U.scalarDivide(IMG_WIDTH);
const PIXEL_DELTA_V = VIEWPORT_V.scalarDivide(IMG_HEIGHT);
const CAMERA_DIRECTION = VIEWPORT_U.cross(VIEWPORT_V).normalize().scalarMultiply(FOCAL_LENGTH);
const VIEWPORT_UL = CAMERA_CENTER.add(CAMERA_DIRECTION).subtract(VIEWPORT_V.scalarMultiply(0.5)).subtract(VIEWPORT_U.multiply(0.5));
const PIXEL_ORIGIN = VIEWPORT_UL.add(PIXEL_DELTA_V.add(PIXEL_DELTA_U).scalarMultiply(0.5));

pub fn main() !void {
    var file = try std.fs.cwd().createFile(IMAGE_FILE, std.fs.File.CreateFlags{ .read = true });
    defer file.close();
    try file.writer().print("P3\n{} {}\n255\n", .{ IMG_WIDTH, IMG_HEIGHT });
    var progress: f32 = 0;
    const totalPixels = IMG_WIDTH * IMG_HEIGHT;

    for (0..IMG_HEIGHT) |j| {
        try printProgressBar(@intFromFloat(progress / totalPixels));
        for (0..IMG_WIDTH) |i| {
            const pixel_color = color.Color.init(@as(f32, @floatFromInt(i)) / (IMG_WIDTH - 1), @as(f32, @floatFromInt(j)) / (IMG_HEIGHT - 1), 0.0);
            try color.writeColor(&file, &pixel_color);
            progress += 100;
        }
    }
}
