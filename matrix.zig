const std = @import("std");

pub fn Matrix(comptime T: type) type {
    return struct {
        width: usize,
        height: usize,
        buffer: []T,

        const Self = @This();

        pub fn init(allocator: std.mem.Allocator, width: usize, height: usize) !Self {
            return .{
                .width = width,
                .height = height,
                .buffer = try allocator.alloc(T, width * height),
            };
        }

        pub fn initFromFile(allocator: std.mem.Allocator, path: []const u8) !Self {
            // Read file into memory.
            const file = try std.fs.cwd().openFile(path, .{});
            defer file.close();

            const contents = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
            defer allocator.free(contents);

            // Split by lines.
            var lines = std.mem.splitScalar(u8, std.mem.trim(u8, contents, "\r\n"), '\n');

            // First pass: determine width and height.
            var width: usize = 0;
            var height: usize = 0;
            while (lines.next()) |line| {
                if (width == 0) width = line.len;
                height += 1;
            }

            // Second pass: fill the buffer.
            lines = std.mem.splitScalar(u8, std.mem.trim(u8, contents, "\r\n"), '\n'); // Reset the iterator.
            var matrix = try Matrix(u8).init(allocator, width, height);

            var y: usize = 0;
            while (lines.next()) |line| : (y += 1) {
                for (line, 0..) |ch, x| {
                    matrix.set(x, y, ch);
                }
            }

            return matrix;
        }

        pub fn initFromText(allocator: std.mem.Allocator, text: []const u8) !Self {
            // Trim leading/trailing newlines or whitespace.
            const trimmed = std.mem.trim(u8, text, "\r\n ");

            // Split into lines.
            var lines = std.mem.splitScalar(u8, trimmed, '\n');

            // First pass: determine width and height.
            var width: usize = 0;
            var height: usize = 0;
            while (lines.next()) |line| {
                if (width == 0) width = line.len;
                height += 1;
            }

            // Second pass: fill the buffer.
            lines = std.mem.splitScalar(u8, trimmed, '\n'); // Reset the iterator.
            var matrix = try Matrix(u8).init(allocator, width, height);

            var y: usize = 0;
            while (lines.next()) |line| : (y += 1) {
                for (line, 0..) |ch, x| {
                    matrix.set(x, y, ch);
                }
            }

            return matrix;
        }

        pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
            allocator.free(self.buffer);
        }

        pub fn get(self: *const Self, x: usize, y: usize) T {
            return self.buffer[y * self.width + x];
        }

        pub fn set(self: *Self, x: usize, y: usize, value: T) void {
            self.buffer[y * self.width + x] = value;
        }

        pub fn print(self: *Self) void {
            for (0..self.height) |y| {
                for (0..self.width) |x| {
                    std.debug.print("{c}", .{self.get(x, y)});
                }
                std.debug.print("\n", .{});
            }
        }
    };
}
