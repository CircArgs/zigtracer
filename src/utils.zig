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

const RndGen = std.rand.DefaultPrng;

pub fn random_f32(rng: *std.rand.DefaultPrng) f32 {
    // Returns a random real in [0,1).
    return rng.random().float(f32);
}
pub fn random_f32_range(rng: *std.rand.DefaultPrng, min: f32, max: f32) f32 {
    return min + random_f32(rng) * (max - min);
}
