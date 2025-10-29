const std = @import("std");
const assert = std.debug.assert;
const sl = @import("slice.zig");

test "slice iterator" {
    const allocator = std.heap.page_allocator;

    var slice = sl.Slice(u32).init(allocator);
    try slice.append(10);
    try slice.append(20);
    try slice.append(30);
    try slice.append(40);
    try slice.append(50);

    assert(slice.len == 5);

    var it = slice.iterator();
    while (it.next()) |item| {
        assert(item > 0);
    }
}
