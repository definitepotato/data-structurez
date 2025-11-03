const std = @import("std");

/// Stores sequence of Nodes which each hold a value of type `T`.
pub fn LinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        const Node = struct {
            value: T,
            next: ?*Node,
        };

        head: ?*Node = null,
        allocator: std.mem.Allocator,
        len: usize,

        /// Creates a managed LinkedList with a `null` head.
        pub fn init(allocator: std.mem.Allocator) Self {
            return .{ .head = null, .allocator = allocator, .len = 0 };
        }

        /// Add a new Node to the beginning of the LinkedList with a `value`.
        pub fn prepend(self: *Self, value: T) !void {
            const new_node = try self.allocator.create(Node);
            new_node.* = Node{ .value = value, .next = self.head };
            self.head = new_node;
            self.len += 1;
        }

        /// Add a new Node to the end of the LinkedList with a `value`.
        pub fn append(self: *Self, value: T) !void {
            const new_node = try self.allocator.create(Node);
            new_node.* = Node{ .value = value, .next = null };

            if (self.head == null) {
                self.head = new_node;
                self.len += 1;
                return;
            }

            var current = self.head;
            while (current.?.next) |next_node| {
                current = next_node;
            }
            current.?.next = new_node;
            self.len += 1;
        }

        /// Insert a new Node with `value` after an existing Node with `after_value`.
        pub fn insert(self: *Self, after_value: T, value: T) !void {
            var current = self.head;
            while (current) |node| {
                if (node.value == after_value) {
                    const new_node = try self.allocator.create(Node);
                    new_node.* = Node{ .value = value, .next = node.next };
                    node.next = new_node;
                    self.len += 1;
                    return;
                }
                current = node.next;
                self.len += 1;
            }
        }

        /// Print the LinkedList to the terminal.
        pub fn print(self: *Self) void {
            var current = self.head;
            while (current) |node| {
                std.debug.print("{} -> ", .{node.value});
                current = node.next;
            }
            std.debug.print("null\n", .{});
        }

        /// Release the backing buffer.
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

/// Stores a two-deminsional grid as rows and columns.
pub fn Matrix(comptime T: type) type {
    return struct {
        allocator: std.mem.Allocator,
        width: usize,
        height: usize,
        buffer: []T,

        const Self = @This();

        /// Creates a managed Matrix of size `width` x `height`.
        pub fn init(allocator: std.mem.Allocator, width: usize, height: usize) !Self {
            const buffer = try allocator.alloc(T, width * height);

            return .{
                .width = width,
                .height = height,
                .buffer = buffer,
                .allocator = allocator,
            };
        }

        /// Create a managed Matrix from an input file at `path`. Path should include filename.
        pub fn initFromFile(allocator: std.mem.Allocator, path: []const u8) !Self {
            // Get a file descriptor.
            const file = try std.fs.cwd().openFile(path, .{});
            defer file.close();

            // Load file contents into memory.
            const contents = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
            defer allocator.free(contents);

            // Trim leading/trailing newlines or whitespace.
            const trimmed = std.mem.trim(u8, contents, "\r\n ");

            // Split by lines.
            var lines = std.mem.splitScalar(u8, trimmed, '\n');

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

        /// Create a managed Matrix from a multi-line const/var.
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

        /// Release the backing buffer.
        pub fn deinit(self: *Self) void {
            self.allocator.free(self.buffer);
        }

        /// Get the value at coord `x`,`y`.
        pub fn get(self: *const Self, x: usize, y: usize) T {
            return self.buffer[y * self.width + x];
        }

        /// Set `value` at coord `x`,`y`.
        pub fn set(self: *Self, x: usize, y: usize, value: T) void {
            self.buffer[y * self.width + x] = value;
        }

        /// Print the Matrix to the terminal.
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

/// A First-In, First-Out abstraction.
pub fn Queue(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        buffer: []T,
        front: usize,
        back: usize,
        count: usize,

        /// Create an empty Queue.
        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .allocator = allocator,
                .buffer = &[_]T{},
                .front = 0,
                .back = 0,
                .count = 0,
            };
        }

        /// Release the backing buffer.
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

        /// Add a new `item` to the back of the Queue.
        pub fn enqueue(self: *Self, item: T) !void {
            if (self.count == self.buffer.len) {
                try self.resize(if (self.buffer.len == 0) 1 else self.buffer.len * 2);
            }
            self.buffer[self.back] = item;
            self.back = (self.back + 1) % self.buffer.len;
            self.count += 1;
        }

        /// Fetch an `item` from the front of the Queue.
        pub fn dequeue(self: *Self) ?T {
            if (self.count == 0) return null;
            const item = self.buffer[self.front];
            self.front = (self.front + 1) % self.buffer.len;
            self.count -= 1;
            return item;
        }

        /// Peek at the next item in the Queue without fetching it.
        pub fn peek(self: *Self) ?T {
            if (self.count == 0) return null;
            return self.buffer[self.front];
        }

        /// Returns `true` if the Queue is empty, otherwise `false`.
        pub fn is_empty(self: *Self) bool {
            return self.count == 0;
        }
    };
}

/// A variable length structure to an underlying array of type `T`. Automatically
/// resizes as needed. Unsafe to use buffer directly as the `resize()` will include
/// junk data in the backing buffer. Tracks the end of the valid data in the backing
/// buffer using `len`.
pub fn Slice(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        buffer: []T,
        len: usize,

        /// Create an empty Slice.
        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .allocator = allocator,
                .buffer = &[_]T{},
                .len = 0,
            };
        }

        /// Release the backing buffer.
        pub fn deinit(self: *Self) void {
            self.allocator.free(self.buffer);
        }

        fn resize(self: *Self, new_capacity: usize) !void {
            const new_buffer = try self.allocator.alloc(T, new_capacity);
            @memcpy(new_buffer[0..self.len], self.buffer[0..self.len]);
            self.allocator.free(self.buffer);
            self.buffer = new_buffer;
        }

        /// Add a new `item` to the end of the buffer.
        pub fn append(self: *Self, item: T) !void {
            // Golang style resizing, we double capacity of buffer if we exceed the boundary.
            if (self.len >= self.buffer.len) {
                try self.resize(if (self.buffer.len == 0) 1 else self.buffer.len * 2);
            }

            self.buffer[self.len] = item;
            self.len += 1;
        }

        /// Returns a sliding window iterator with a width of `size`.
        pub fn window(self: *Self, size: usize) SliceWindowIterator {
            return SliceWindowIterator{ .slice = self, .window_size = size, .window_start = 0 };
        }

        pub const SliceWindowIterator = struct {
            slice: *Self,
            window_size: usize,
            window_start: usize,

            /// Iterates the backing buffer in a sliding window.
            pub fn next(self: *SliceWindowIterator) ?[]T {
                const window_end = self.window_start + self.window_size;
                if (window_end > self.slice.len) {
                    return null;
                }

                const window_slice = self.slice.buffer[self.window_start..window_end];
                self.window_start += 1;
                return window_slice;
            }
        };

        /// Returns an iterator, use `next()` to iterate.
        pub fn iterator(self: *Self) SliceIterator {
            return SliceIterator{ .slice = self, .index = 0 };
        }

        pub const SliceIterator = struct {
            slice: *Self,
            index: usize,

            /// Iterates the backing buffer item by item.
            pub fn next(self: *SliceIterator) ?T {
                if (self.index >= self.slice.len) {
                    return null;
                }

                const item = self.slice.buffer[self.index];
                self.index += 1;
                return item;
            }
        };

        /// The caller owns the returned memory. Does not empty the backing buffer.
        pub fn toOwned(self: Self) !?[]T {
            if (self.len > 0) {
                const items = self.buffer[0..self.len];
                if (self.allocator.alloc(T, items.len)) |slice_Ts| {
                    std.mem.copyForwards(T, slice_Ts, items);
                    return slice_Ts;
                } else |_| {
                    return std.mem.Allocator.Error.OutOfMemory;
                }
            }

            return null;
        }
    };
}

/// A Last-In, First-Out abstraction.
pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        buffer: []T,
        top: usize,

        /// Create an empty Stack.
        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .allocator = allocator,
                .buffer = &[_]T{},
                .top = 0,
            };
        }

        /// Release the backing buffer.
        pub fn deinit(self: *Self) void {
            self.allocator.free(self.buffer);
        }

        pub fn resize(self: *Self, new_capacity: usize) !void {
            const new_buffer = try self.allocator.alloc(T, new_capacity);
            @memcpy(new_buffer[0..self.top], self.buffer[0..self.top]);
            self.allocator.free(self.buffer);
            self.buffer = new_buffer;
        }

        /// Push an `item` onto the stop of the Stack.
        pub fn push(self: *Self, item: T) !void {
            if (self.top >= self.buffer.len) {
                try self.resize(if (self.buffer.len == 0) 1 else self.buffer.len * 2);
            }
            self.buffer[self.top] = item;
            self.top += 1;
        }

        /// Fetch an item from the top of the Stack.
        pub fn pop(self: *Self) ?T {
            if (self.top == 0) return null;
            self.top -= 1;
            return self.buffer[self.top];
        }

        /// Peek at the next item in the Stack without fetching it.
        pub fn peek(self: *Self) ?T {
            if (self.top == 0) return null;
            return self.buffer[self.top - 1];
        }

        /// Returns `true` if the Stack is empty, otherwise `false`.
        pub fn is_empty(self: *Self) bool {
            return self.top == 0;
        }

        /// The caller owns the returned memory. Does not empty the backing buffer.
        pub fn toOwned(self: Self) !?[]T {
            if (self.top > 0) {
                const items = self.buffer[0..self.top];
                if (self.allocator.alloc(T, items.len)) |slice_Ts| {
                    std.mem.copyForwards(T, slice_Ts, items);
                    return slice_Ts;
                } else |_| {
                    return std.mem.Allocator.Error.OutOfMemory;
                }
            }

            return null;
        }
    };
}
