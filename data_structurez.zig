const std = @import("std");

pub fn LinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        const Node = struct {
            value: T,
            next: ?*Node,
        };

        head: ?*Node = null,
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{ .head = null, .allocator = allocator };
        }

        pub fn prepend(self: *Self, value: T) !void {
            const new_node = try self.allocator.create(Node);
            new_node.* = Node{ .value = value, .next = self.head };
            self.head = new_node;
        }

        pub fn append(self: *Self, value: T) !void {
            const new_node = try self.allocator.create(Node);
            new_node.* = Node{ .value = value, .next = null };

            if (self.head == null) {
                self.head = new_node;
                return;
            }

            var current = self.head;
            while (current.?.next) |next_node| {
                current = next_node;
            }
            current.?.next = new_node;
        }

        pub fn insert(self: *Self, after_value: T, value: T) !void {
            var current = self.head;
            while (current) |node| {
                if (node.value == after_value) {
                    const new_node = try self.allocator.create(Node);
                    new_node.* = Node{ .value = value, .next = node.next };
                    node.next = new_node;
                    return;
                }
                current = node.next;
            }
        }

        pub fn print(self: *Self) void {
            var current = self.head;
            while (current) |node| {
                std.debug.print("{} -> ", .{node.value});
                current = node.next;
            }
            std.debug.print("null\n", .{});
        }

        pub fn deinit(self: *Self) void {
            var current = self.head;
            while (current) |node| {
                const next = node.next;
                self.allocator.destroy(node);
                current = next;
            }
            self.head = null;
        }
    };
}

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
                if (self.allocator.alloc(T, items.len)) |slice_Ts| {
                    std.mem.copyForwards(T, slice_Ts, items);
                    return slice_Ts;
                } else |_| {
                    return Error.OutOfMemory;
                }
            }

            return null;
        }
    };
}
