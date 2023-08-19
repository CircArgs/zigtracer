const math = @import("std").math;

const Self = @This();

min: f32,
max: f32,

pub fn init(min: f32, max: f32) Self {
    return Self{ .min = min, .max = max };
}

pub fn default() Self {
    return Self{ .min = 0, .max = math.inf(f32) };
}

pub fn empty() Self {
    return Self{ .min = math.inf(f32), .max = -math.inf(f32) };
}

pub fn universe() Self {
    return Self{ .min = -math.inf(f32), .max = math.inf(f32) };
}

pub fn contains(self: *const Self, x: f32) bool {
    return self.min <= x and x <= self.max;
}

pub fn surrounds(self: *const Self, x: f32) bool {
    return self.min < x and x < self.max;
}

pub fn clamp(self: *const Self, x: f32) f32 {
    return @min(@max(x, self.min), self.max);
}
