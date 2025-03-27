const std = @import("std");
const assert = std.debug.assert;
const ds = @import("queue.zig");

test "usize queue structure" {
    const allocator = std.testing.allocator;

    var queue = ds.Queue(usize).init(allocator);
    defer queue.deinit();

    assert(queue.is_empty());

    try queue.enqueue(10);
    try queue.enqueue(20);
    assert(queue.peek().? == 10);

    _ = queue.dequeue().?;
    assert(queue.peek().? == 20);

    try queue.enqueue(30);
    try queue.enqueue(40);
    assert(queue.is_empty() == false);
}

test "u8 queue structure" {
    const allocator = std.testing.allocator;

    var queue = ds.Queue(u8).init(allocator);
    defer queue.deinit();

    assert(queue.is_empty());

    try queue.enqueue('a');
    try queue.enqueue('b');
    assert(queue.peek().? == 'a');

    _ = queue.dequeue().?;
    assert(queue.peek().? == 'b');

    try queue.enqueue('c');
    try queue.enqueue('d');
    assert(queue.is_empty() == false);
}
