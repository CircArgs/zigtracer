const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn printProgressBar(progress: u32) !void {
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
