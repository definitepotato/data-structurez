const std = @import("std");
const ds = @import("linked-list.zig");

test "linked list" {
    const allocator = std.testing.allocator;

    var list = ds.LinkedList(usize).init(allocator);
    defer list.deinit();

    try list.prepend(10);
    try list.prepend(20);
    try list.prepend(30);

    if (list.head) |head| {
        try std.testing.expect(head.*.value == 30);
        if (head.next) |node| {
            try std.testing.expect(node.*.value == 20);
        }
    }
}
