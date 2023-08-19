//! This module provides some convenience functions for use with `Color`

const std = @import("std");
const Interval = @import("interval.zig");
pub const Color = @import("vec3.zig");

const CHANNEL_INTERVAL = Interval.init(0, 1);

/// Writes a color out to the given stream
pub fn writeColor(stream: *const std.fs.File, color: *const Color) !void {
    // by convention, r/g/b range from 0.0-1.0
    const ir = @as(i32, @intFromFloat(255.999 * CHANNEL_INTERVAL.clamp(color.getX())));
    const ig = @as(i32, @intFromFloat(255.999 * CHANNEL_INTERVAL.clamp(color.getY())));
    const ib = @as(i32, @intFromFloat(255.999 * CHANNEL_INTERVAL.clamp(color.getZ())));

    try stream.writer().print("{} {} {}\n", .{ ir, ig, ib });
}
