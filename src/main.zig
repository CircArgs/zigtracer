const std = @import("std");
const print = std.debug.print;
const stdout = std.io.getStdOut().writer();

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
    print("P3\n{} {}\n255\n", .{ IMG_WIDTH, IMG_HEIGHT });
    var r: f64 = 0;
    var g: f64 = 0;
    var b: f64 = 0;
    _ = b;
    var progress: f32 = 0;
    const totalPixels = IMG_WIDTH * IMG_HEIGHT;

    for (0..IMG_HEIGHT) |j| {
        try printProgressBar(@intFromFloat(progress / totalPixels));
        for (0..IMG_WIDTH) |i| {
            r = @as(f64, @floatFromInt(i)) / (IMG_WIDTH - 1);
            g = @as(f64, @floatFromInt(j)) / (IMG_HEIGHT - 1);

            print("{} {} {}\n", .{ @as(i64, @intFromFloat(255.999 * r)), @as(i64, @intFromFloat(255.999 * g)), @as(i64, 0) });

            progress += 100;
        }
    }
}
