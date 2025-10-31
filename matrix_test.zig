const std = @import("std");
const ds = @import("matrix.zig");

test "3x5 matrix from text" {
    const test_input =
        \\#.##.
        \\..#..
        \\##..#
    ;

    const allocator = std.heap.page_allocator;

    const matrix = try ds.Matrix(u8).initFromText(allocator, test_input);

    try std.testing.expectEqual(matrix.height, 3);
    try std.testing.expectEqual(matrix.width, 5);
    try std.testing.expect(matrix.data.len > 0);
}

test "3x5 matrix from file" {
    const allocator = std.heap.page_allocator;

    const matrix = try ds.Matrix(u8).initFromFile(allocator, "matrix_input.txt");

    try std.testing.expectEqual(matrix.height, 3);
    try std.testing.expectEqual(matrix.width, 5);
    try std.testing.expect(matrix.data.len > 0);
}
