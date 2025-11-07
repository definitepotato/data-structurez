# Data Structurez

A tiny library of data structures written in pure Zig. Use for learning and experimenting. I write potato code so please don't use in production projects.

## What's Inside

| Data Structure | Methods                                                                         |
| -------------- | ------------------------------------------------------------------------------- |
| Linked List    | `init()` `deinit()` `prepend()` `insert()` `print()`                            |
| Matrix         | `init()` `deinit()` `initFromFile` `initFromText` `getXY()` `setXY()` `print()` |
| Queue          | `init()` `deinit()` `enqueue()` `dequeue()` `peek()` `is_empty()`               |
| Stack          | `init()` `deinit()` `push()` `pop()` `peek()` `is_empty()` `toOwned()`          |
| Slice          | `init()` `deinit()` `append()` `iterator()` `window()` `backward()` `toOwned()` |

## How To Use It

Drop the `data_structurez.zig` file in your project and import like `std ds = @import("data_structurez.zig")`

or

In your project folder run `zig fetch --save https://github.com/definitepotato/data-structurez.git` and in your `build.zig` file add:

```zig
const data_structurez_dep = b.dependency("data_structurez", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("data_structurez", data_structurez_dep.module("data_structurez"));
```

### Linked List

```zig
const std = @import("std");
const ds = @import("data_structurez.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var list = ds.LinkedList(usize).init(allocator);
    defer list.deinit();

    try list.prepend(10);
    try list.prepend(20);
    try list.prepend(30);

    list.print();
}

// Output:
// 30 -> 20 -> 10 -> null
```

### Matrix

```zig
const std = @import("std");
const ds = @import("data_structurez.zig");

const input_test =
    \\MMMSXXMASM
    \\MSAMXMSMSA
    \\AMXSXMAAMM
    \\MSAMASMSMX
    \\XMASAMXAMM
    \\XXAMMXXAMA
    \\SMSMSASXSS
    \\SAXAMASAAA
    \\MAMMMXMMMM
    \\MXMXAXMASX
;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var matrix = try ds.Matrix(u8).initFromText(allocator, input_test);
    defer matrix.deinit();

    for (0..matrix.height) |y| {
        for (0..matrix.width) |x| {
            const loc = matrix.getXY(x, y);
            if (loc == 'X') {
                std.debug.print("X => {d},{d}\n", .{ x, y });
            }
        }
    }
}

// Output:
// X => 4,0
// X => 5,0
// X => 4,1
// X => 2,2
// X => 4,2
// X => 9,3
// X => 0,4
// X => 6,4
// X => 0,5
// X => 1,5
// X => 5,5
// X => 6,5
// X => 7,6
// X => 2,7
// X => 5,8
// X => 1,9
// X => 3,9
// X => 5,9
// X => 9,9
```

## Queue

```zig
const std = @import("std");
const ds = @import("data_structurez.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var queue = ds.Queue(u8).init(allocator);
    defer queue.deinit();

    try queue.enqueue('a');
    try queue.enqueue('b');

    const next = queue.peek().?;
    std.debug.print("{c}\n", .{next});
}

// Output:
// a
```

## Stack

```zig
const std = @import("std");
const ds = @import("data_structurez.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var stack = ds.Stack(u8).init(allocator);
    defer stack.deinit();

    try stack.push('a');
    try stack.push('b');
    _ = stack.pop().?;
    try stack.push('c');

    std.debug.print("{}\n", .{stack.is_empty()});
}

// Output:
// false
```

## Slice

```zig
const std = @import("std");
const ds = @import("data_structurez.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var slice = ds.Slice(u32).init(allocator);
    try slice.append(10);
    try slice.append(20);
    try slice.append(30);
    try slice.append(40);
    try slice.append(50);

    std.debug.print("Len: {d}\n", .{slice.len});

    var it = slice.iterator();
    while (it.next()) |item| {
        std.debug.print("{d}\n", .{item});
    }
}

// Output:
// Len: 5
// 10
// 20
// 30
// 40
// 50
```
