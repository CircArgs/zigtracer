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

pub fn init(aspect_ratio: f32, image_width: u32) Self {
    return Self{ .aspect_ratio = aspect_ratio, .image_width = image_width };
}

pub fn render(self: *const Self, world: *const objects.HittableList, stream: *const std.fs.File) !void {
    const settings = CameraSettings.init(self.aspect_ratio, self.image_width);
    var progress: f32 = 0;
    const total_pixels = settings.image_width * settings.image_height;
    for (0..settings.image_height) |j| {
        try utils.printProgressBar(@intFromFloat(progress / total_pixels));
        for (0..settings.image_width) |i| {
            const pixel_loc = settings.pixel_origin.add(&settings.pixel_delta_v.scalarMultiply(@as(f32, @floatFromInt(j))).add(&settings.pixel_delta_u.scalarMultiply(@as(f32, @floatFromInt(i)))));
            const ray_direction = pixel_loc.subtract(&settings.camera_center);
            const pixel_color = rayColor(&Ray.init(&settings.camera_center, ray_direction), &world);
            try color.writeColor(&stream, &pixel_color);

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

    pub fn init(aspect_ratio: f32, image_width: u32) CameraSettings {
        var image_height = @as(i32, @floor(image_width / aspect_ratio));
        if (image_height < 1) {
            image_height = 1;
        }

        // Determine viewport dimensions.
        const viewport_height: comptime_float = 2.0;
        const viewport_width: comptime_float = viewport_height * @as(f32, @floatCast(image_width)) / @as(f32, @floatCast(image_height));

        // Calculate the vectors across the horizontal and down the vertical viewport edges.
        const viewport_u = Vec3.init(viewport_width, 0, 0);
        const viewport_v = Vec3.init(0, -viewport_height, 0);

        // Calculate the horizontal and vertical delta vectors from pixel to pixel.
        const pixel_delta_u = viewport_u.scalarDivide(image_width);
        const pixel_delta_v = viewport_v.scalarDivide(image_height);
        const center = Point3.init(0, 0, 0);

        // Calculate the location of the upper left pixel.
        const viewport_upper_left = center.subtract(&Vec3.init(0, 0, FOCAL_LENGTH)).subtract(&viewport_u.scalarDivide(2)).subtract(&viewport_v.scalarDivide(2));
        const pixel_origin = viewport_upper_left.add(&pixel_delta_u.scalarMultiply(0.5)).add(&pixel_delta_v.scalarMultiply(0.5));

        return CameraSettings{ .aspect_ratio = aspect_ratio, .image_width = image_width, .image_height = image_height, .center = center, .pixel_origin = pixel_origin, .pixel_delta_u = pixel_delta_u, .pixel_delta_v = pixel_delta_v };
    }
};
