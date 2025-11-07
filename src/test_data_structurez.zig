const std = @import("std");
const ds = @import("data_structurez.zig");

test "linked list" {
    const allocator = std.testing.allocator;

    var list = ds.LinkedList(usize).init(allocator);
    defer list.deinit();

    try list.prepend(30);
    try std.testing.expect(list.head.?.*.value == 30);
    try std.testing.expect(list.len == 1);

    try list.append(40);
    if (list.head) |head| {
        try std.testing.expect(head.*.value == 30);
        if (head.next) |node| {
            try std.testing.expect(node.*.value == 40);
        }
    }
    try std.testing.expect(list.len == 2);

    try list.insert(30, 50);
    if (list.head) |head| {
        try std.testing.expect(head.*.value == 30);
        if (head.next) |node| {
            try std.testing.expect(node.*.value == 50);
        }
    }
    try std.testing.expect(list.len == 3);
}

test "matrix 3x5 from text" {
    const test_input =
        \\#.##.
        \\..#..
        \\##..#
    ;

    const allocator = std.testing.allocator;

    var matrix = try ds.Matrix(u8).initFromText(allocator, test_input);
    defer matrix.deinit();

    try std.testing.expectEqual(matrix.height, 3);
    try std.testing.expectEqual(matrix.width, 5);
    try std.testing.expect(matrix.buffer.len > 0);
    try std.testing.expectEqual(matrix.getXY(0, 0), '#');

    matrix.setXY(0, 0, '.');
    try std.testing.expectEqual(matrix.getXY(0, 0), '.');
}

test "matrix 3x5 from file" {
    const allocator = std.testing.allocator;

    var matrix = try ds.Matrix(u8).initFromFile(allocator, "matrix_input.txt");
    defer matrix.deinit();

    try std.testing.expectEqual(matrix.height, 3);
    try std.testing.expectEqual(matrix.width, 5);
    try std.testing.expect(matrix.buffer.len > 0);
    try std.testing.expectEqual(matrix.getXY(0, 0), '#');

    matrix.setXY(0, 0, '.');
    try std.testing.expectEqual(matrix.getXY(0, 0), '.');
}

test "queue u8" {
    const allocator = std.testing.allocator;

    var queue = ds.Queue(u8).init(allocator);
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

test "slice u32" {
    const allocator = std.testing.allocator;

    var slice = ds.Slice(u32).init(allocator);
    defer slice.deinit();

    try slice.append(10);
    try slice.append(20);
    try slice.append(30);
    try slice.append(40);
    try slice.append(50);

    std.debug.assert(slice.len == 5);

    var it = slice.iterator();
    var count_it: u32 = 10;
    while (it.next()) |item| {
        std.debug.assert(item == count_it);
        count_it += 10;
    }

    var bit = slice.backward();
    var count_bit: u32 = 50;
    while (bit.next()) |item| {
        std.debug.assert(item == count_bit);
        count_bit -= 10;
    }

    var window = slice.window(3);
    while (window.next()) |item| {
        std.debug.assert(item.len == 3);
    }

    const owned_slice = try slice.toOwned();
    if (owned_slice) |s| {
        defer allocator.free(s);
        std.debug.assert(s.len > 0);
    }
}

test "stack u8" {
    const allocator = std.testing.allocator;

    var stack = ds.Stack(u8).init(allocator);
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
