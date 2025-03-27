const std = @import("std");

pub fn Queue(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        buffer: []T,
        front: usize,
        back: usize,
        count: usize,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .allocator = allocator,
                .buffer = &[_]T{},
                .front = 0,
                .back = 0,
                .count = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.buffer);
        }

        fn resize(self: *Self, new_capacity: usize) !void {
            const new_buffer = try self.allocator.alloc(T, new_capacity);

            // Copy elements in order from front to back
            for (0..self.count) |i| {
                new_buffer[i] = self.buffer[(self.front + i) % self.buffer.len];
            }

            self.allocator.free(self.buffer);
            self.buffer = new_buffer;
            self.front = 0;
            self.back = self.count;
        }

        pub fn enqueue(self: *Self, item: T) !void {
            if (self.count == self.buffer.len) {
                try self.resize(if (self.buffer.len == 0) 1 else self.buffer.len * 2);
            }
            self.buffer[self.back] = item;
            self.back = (self.back + 1) % self.buffer.len;
            self.count += 1;
        }

        pub fn dequeue(self: *Self) ?T {
            if (self.count == 0) return null;
            const item = self.buffer[self.front];
            self.front = (self.front + 1) % self.buffer.len;
            self.count -= 1;
            return item;
        }

        pub fn peek(self: *Self) ?T {
            if (self.count == 0) return null;
            return self.buffer[self.front];
        }

        pub fn is_empty(self: *Self) bool {
            return self.count == 0;
        }
    };
}
