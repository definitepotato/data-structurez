const std = @import("std");
const assert = std.debug.assert;
const ds = @import("stack.zig");

test "usize stack structure" {
    const allocator = std.testing.allocator;

    var stack = ds.Stack(usize).init(allocator);
    defer stack.deinit();

    assert(stack.is_empty());

    try stack.push(10);
    try stack.push(20);
    assert(stack.peek().? == 20);

    _ = stack.pop().?;
    assert(stack.peek().? == 10);

    try stack.push(30);
    try stack.push(40);
    assert(stack.is_empty() == false);
}

test "u8 stack structure" {
    const allocator = std.testing.allocator;

    var stack = ds.Stack(u8).init(allocator);
    defer stack.deinit();

    assert(stack.is_empty());

    try stack.push('a');
    try stack.push('b');
    assert(stack.peek().? == 'b');

    _ = stack.pop().?;
    assert(stack.peek().? == 'a');

    try stack.push('c');
    try stack.push('d');
    assert(stack.is_empty() == false);
}
