const std = @import("std");
const Vec3 = @import("vec3.zig");
const color = @import("color.zig");

const stdout = std.io.getStdOut().writer();

const imagefile = "image.ppm";
const IMG_WIDTH = 256;
const IMG_HEIGHT = 256;

fn printProgressBar(progress: u32) !void {
    const remaining = 100 - progress;

    try stdout.print("[", .{});
    for (0..progress) |i| {
        _ = i;
        try stdout.print("=", .{});
    }
    for (0..remaining) |i| {
        _ = i;
        try stdout.print(" ", .{});
    }
    try stdout.print("] {}%\r", .{progress});
}

pub fn main() !void {
    var file = try std.fs.cwd().createFile(imagefile, std.fs.File.CreateFlags{ .read = true });
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
