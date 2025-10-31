const std = @import("std");
const DataStructures = @import("data_structurez.zig");

test "linked list" {
    const allocator = std.testing.allocator;

    var list = DataStructures.LinkedList(usize).init(allocator);
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

test "matrix 3x5 from text" {
    const test_input =
        \\#.##.
        \\..#..
        \\##..#
    ;

    const allocator = std.testing.allocator;

    var matrix = try DataStructures.Matrix(u8).initFromText(allocator, test_input);

    try std.testing.expectEqual(matrix.height, 3);
    try std.testing.expectEqual(matrix.width, 5);
    try std.testing.expect(matrix.buffer.len > 0);
    try std.testing.expectEqual(matrix.get(0, 0), '#');

    matrix.set(0, 0, '.');
    try std.testing.expectEqual(matrix.get(0, 0), '.');
}

test "matrix 3x5 from file" {
    const allocator = std.testing.allocator;

    var matrix = try DataStructures.Matrix(u8).initFromFile(allocator, "matrix_input.txt");

    try std.testing.expectEqual(matrix.height, 3);
    try std.testing.expectEqual(matrix.width, 5);
    try std.testing.expect(matrix.buffer.len > 0);
    try std.testing.expectEqual(matrix.get(0, 0), '#');

    matrix.set(0, 0, '.');
    try std.testing.expectEqual(matrix.get(0, 0), '.');
}

test "queue usize" {
    const allocator = std.testing.allocator;

    var queue = DataStructures.Queue(usize).init(allocator);
    defer queue.deinit();

    std.debug.assert(queue.is_empty());

    try queue.enqueue(10);
    try queue.enqueue(20);
    std.debug.assert(queue.peek().? == 10);

    _ = queue.dequeue().?;
    std.debug.assert(queue.peek().? == 20);

    try queue.enqueue(30);
    try queue.enqueue(40);
    std.debug.assert(queue.is_empty() == false);
}

test "queue u8" {
    const allocator = std.testing.allocator;

    var queue = DataStructures.Queue(u8).init(allocator);
    defer queue.deinit();

    std.debug.assert(queue.is_empty());

    try queue.enqueue('a');
    try queue.enqueue('b');
    std.debug.assert(queue.peek().? == 'a');

    _ = queue.dequeue().?;
    std.debug.assert(queue.peek().? == 'b');

    try queue.enqueue('c');
    try queue.enqueue('d');
    std.debug.assert(queue.is_empty() == false);
}

test "slice iterator" {
    const allocator = std.testing.allocator;

    var slice = DataStructures.Slice(u32).init(allocator);
    try slice.append(10);
    try slice.append(20);
    try slice.append(30);
    try slice.append(40);
    try slice.append(50);

    std.debug.assert(slice.len == 5);

    var it = slice.iterator();
    while (it.next()) |item| {
        std.debug.assert(item > 0);
    }
}

test "stack usize" {
    const allocator = std.testing.allocator;

    var stack = DataStructures.Stack(usize).init(allocator);
    defer stack.deinit();

    std.debug.assert(stack.is_empty());

    try stack.push(10);
    try stack.push(20);
    std.debug.assert(stack.peek().? == 20);

    _ = stack.pop().?;
    std.debug.assert(stack.peek().? == 10);

    try stack.push(30);
    try stack.push(40);
    std.debug.assert(stack.is_empty() == false);

    const slice = try stack.toOwned();
    if (slice) |s| {
        defer allocator.free(s);

        const expected_slice = &[_]usize{ 10, 30, 40 };
        try std.testing.expectEqualSlices(usize, s, expected_slice);
    }
}

test "stack u8" {
    const allocator = std.testing.allocator;

    var stack = DataStructures.Stack(u8).init(allocator);
    defer stack.deinit();

    std.debug.assert(stack.is_empty());

    try stack.push('a');
    try stack.push('b');
    std.debug.assert(stack.peek().? == 'b');

    _ = stack.pop().?;
    std.debug.assert(stack.peek().? == 'a');

    try stack.push('c');
    try stack.push('d');
    std.debug.assert(stack.is_empty() == false);

    const slice = try stack.toOwned();
    if (slice) |s| {
        defer allocator.free(s);

        const expected_slice = &[_]u8{ 'a', 'c', 'd' };
        try std.testing.expectEqualSlices(u8, s, expected_slice);
    }
}
