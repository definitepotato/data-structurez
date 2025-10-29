const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

pub fn Slice(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        buffer: []T,
        len: usize,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .allocator = allocator,
                .buffer = &[_]T{},
                .len = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.buffer);
        }

        fn resize(self: *Self, new_capacity: usize) !void {
            const new_buffer = try self.allocator.alloc(T, new_capacity);
            @memcpy(new_buffer[0..self.len], self.buffer[0..self.len]);
            self.allocator.free(self.buffer);
            self.buffer = new_buffer;
        }

        pub fn append(self: *Self, item: T) !void {
            if (self.len >= self.buffer.len) {
                try self.resize(if (self.buffer.len == 0) 1 else self.buffer.len * 2);
            }

            self.buffer[self.len] = item;
            self.len += 1;
        }

        pub fn iterator(self: *Self) SliceIterator {
            return SliceIterator{ .slice = self, .index = 0 };
        }

        pub const SliceIterator = struct {
            slice: *Self,
            index: usize,

            pub fn next(self: *SliceIterator) ?T {
                if (self.index >= self.slice.len) {
                    return null;
                }

                const item = self.slice.buffer[self.index];
                self.index += 1;
                return item;
            }
        };
    };
}
