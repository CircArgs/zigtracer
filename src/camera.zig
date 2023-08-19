const std = @import("std");
const utils = @import("utils");
const objects = @import("objects");
const core = @import("core");
const Ray = core.Ray;
const Point3 = Ray.Point3;
const Vec3 = core.Vec3;
const color = core.color;
const Interval = core.Interval;

const FOCAL_LENGTH = 1.0;

const Self = @This();

aspect_ratio: f32,
image_width: u32,
samples_per_pixel: u32,

pub fn init(aspect_ratio: f32, image_width: u32, samples_per_pixel: u32) Self {
    return Self{ .aspect_ratio = aspect_ratio, .image_width = image_width, .samples_per_pixel = samples_per_pixel };
}

fn get_ray(settings: *const CameraSettings, i: f32, j: f32) Ray {
    const pixel_loc = settings.pixel_origin.add(&settings.pixel_delta_v.scalarMultiply(j)).add(&settings.pixel_delta_u.scalarMultiply(i));
    const ray_direction = pixel_loc.subtract(&settings.center);
    return Ray.init(settings.center, ray_direction);
}

pub fn render(self: *const Self, world: *const objects.HittableList, stream: *const std.fs.File) !void {
    var settings = CameraSettings.init(self.aspect_ratio, self.image_width);
    try stream.writer().print("P3\n{} {}\n255\n", .{ settings.image_width, settings.image_height });
    var progress: f32 = 0;
    const total_pixels = @as(f32, @floatFromInt(settings.image_width * settings.image_height));
    for (0..settings.image_height) |j| {
        try utils.printProgressBar(@intFromFloat(progress / total_pixels));
        for (0..settings.image_width) |i| {
            var pixel_color = color.Color.init(0, 0, 0);
            for (0..self.samples_per_pixel) |_| {
                const rnd_i = utils.random_f32_range(&settings.rng, -0.5, 0.5);
                const rnd_j = utils.random_f32_range(&settings.rng, -0.5, 0.5);
                const this_ray = get_ray(&settings, rnd_i + @as(f32, @floatFromInt(i)), rnd_j + @as(f32, @floatFromInt(j)));
                const this_color = rayColor(&this_ray, world);
                pixel_color = pixel_color.add(&this_color);
            }
            pixel_color = pixel_color.scalarDivide(@as(f32, @floatFromInt(self.samples_per_pixel)));
            try color.writeColor(stream, &pixel_color);

            progress += 100;
        }
    }
}

fn rayColor(r: *const Ray, world: *const objects.HittableList) color.Color {
    var interval = Interval.default();
    const hit = world.hit(r, &interval);
    if (hit != null) {
        return (hit.?).normal.add(&Vec3.init(1, 1, 1)).scalarDivide(2);
    }

    const unit_direction = r.direction.normalize();
    const a = 0.5 * (unit_direction.getY() + 1);
    return (color.Color.init(1.0, 1.0, 1.0).scalarMultiply(1.0 - a)).add(&color.Color.init(0.5, 0.7, 1.0).scalarMultiply(a));
}

const CameraSettings = struct {
    aspect_ratio: f32,
    image_width: u32,
    image_height: u32,
    center: Point3,
    pixel_origin: Vec3,
    pixel_delta_u: Vec3,
    pixel_delta_v: Vec3,
    rng: std.rand.DefaultPrng,

    pub fn init(aspect_ratio: f32, image_width: u32) CameraSettings {
        const image_width_ = @as(f32, @floatFromInt(image_width));
        var image_height_ = @floor(image_width_ / aspect_ratio);
        if (image_height_ < 1) {
            image_height_ = 1;
        }
        const image_height = @as(u32, @intFromFloat(image_height_));

        // Determine viewport dimensions.
        const viewport_height: f32 = 2.0;
        const viewport_width: f32 = viewport_height * image_width_ / image_height_;

        // Calculate the vectors across the horizontal and down the vertical viewport edges.
        const viewport_u = Vec3.init(viewport_width, 0, 0);
        const viewport_v = Vec3.init(0, -viewport_height, 0);

        // Calculate the horizontal and vertical delta vectors from pixel to pixel.
        const pixel_delta_u = viewport_u.scalarDivide(image_width_);
        const pixel_delta_v = viewport_v.scalarDivide(image_height_);
        const center = Point3.init(0, 0, 0);

        // Calculate the location of the upper left pixel.
        const viewport_upper_left = center.subtract(&Vec3.init(0, 0, FOCAL_LENGTH)).subtract(&viewport_u.scalarDivide(2)).subtract(&viewport_v.scalarDivide(2));
        const pixel_origin = viewport_upper_left.add(&pixel_delta_u.scalarMultiply(0.5)).add(&pixel_delta_v.scalarMultiply(0.5));
        const seed = @as(u64, @truncate(@as(u128, @bitCast(std.time.nanoTimestamp()))));
        var prng = std.rand.DefaultPrng.init(seed);
        return CameraSettings{ .aspect_ratio = aspect_ratio, .image_width = image_width, .image_height = image_height, .center = center, .pixel_origin = pixel_origin, .pixel_delta_u = pixel_delta_u, .pixel_delta_v = pixel_delta_v, .rng = prng };
    }
};
