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
