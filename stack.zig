const std = @import("std");

pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        buffer: []T,
        top: usize,

        pub const Error = error{
            OutOfMemory,
        };

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .allocator = allocator,
                .buffer = &[_]T{},
                .top = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.buffer);
        }

        pub fn resize(self: *Self, new_capacity: usize) !void {
            const new_buffer = try self.allocator.alloc(T, new_capacity);
            @memcpy(new_buffer[0..self.top], self.buffer[0..self.top]);
            self.allocator.free(self.buffer);
            self.buffer = new_buffer;
        }

        pub fn push(self: *Self, item: T) !void {
            if (self.top >= self.buffer.len) {
                try self.resize(if (self.buffer.len == 0) 1 else self.buffer.len * 2);
            }
            self.buffer[self.top] = item;
            self.top += 1;
        }

        pub fn pop(self: *Self) ?T {
            if (self.top == 0) return null;
            self.top -= 1;
            return self.buffer[self.top];
        }

        pub fn peek(self: *Self) ?T {
            if (self.top == 0) return null;
            return self.buffer[self.top - 1];
        }

        pub fn is_empty(self: *Self) bool {
            return self.top == 0;
        }

        pub fn toOwned(self: Self) Error!?[]T {
            if (self.top > 0) {
                const items = self.buffer[0..self.top];
                if (self.allocator.alloc(T, items.len)) |newT| {
                    std.mem.copyForwards(T, newT, items);
                    return newT;
                } else |_| {
                    return Error.OutOfMemory;
                }
            }

            return null;
        }
    };
}
