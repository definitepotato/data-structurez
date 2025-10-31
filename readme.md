# Data Structurez

A tiny library of data structures written in pure Zig. Use for learning and experimenting. I write potato code so please don't use in production projects.

## What's Inside

| Data Structure | Methods                                                                     |
| -------------- | --------------------------------------------------------------------------- |
| Linked List    | `init()` `deinit()` `prepend()` `insert()` `print()`                        |
| Matrix         | `init()` `deinit()` `initFromFile` `initFromText` `get()` `set()` `print()` |
| Queue          | `init()` `deinit()` `enqueue()` `dequeue()` `peek()` `is_empty()`           |
| Stack          | `init()` `deinit()` `push()` `pop()` `peek()` `is_empty()` `toOwned()`      |
| Slice          | `init()` `deinit()` `append()` `iterator()`                                 |

## How To Use It

Drop the `data-structurez.zig` file in your project and import like `std DataStructures = @import("data-structurez.zig")`

### Linked List

```zig
const std = @import("std");
const DataStructures = @import("data-structurez.zig")

const allocator = std.heap.page_allocator;

var list = DataStructures.LinkedList(usize).init(allocator);
defer list.deinit();

try list.prepend(10);
try list.prepend(20);
try list.prepend(30);

list.print();
```

### Matrix

```zig
const std = @import("std");
const DataStructures = @import("data-structurez.zig")

const allocator = std.head.page_allocator;

var matrix = try DataStructures.Matrix(u8).initFromFile(allocator, "matrix_input.txt");
defer matrix.deinit();

matrix.print();
```

## Queue

```zig
const std = @import("std");
const DataStructures = @import("data-structurez.zig")

const allocator = std.heap.page_allocator;

var queue = DataStructures.Queue(u8).init(allocator);
defer queue.deinit();

try queue.enqueue('a');
try queue.enqueue('b');

const next = queue.peek().?;
std.debug.print("{c}\n", .{next});
```

## Stack

```zig
const std = @import("std");
const DataStructures = @import("data-structurez.zig")

const allocator = std.heap.page_allocator;

var stack = DataStructures.Stack(u8).init(allocator);
defer stack.deinit();

try stack.push('a');
try stack.push('b');
_ = stack.pop().?;
try stack.push('c');

std.debug.print("{}\n", .{stack.is_empty()});
```

## Slice

```zig
const std = @import("std");
const DataStructures = @import("data-structurez.zig")

const allocator = std.heap.page_allocator;

var slice = DataStructures.Slice(u32).init(allocator);
try slice.append(10);
try slice.append(20);
try slice.append(30);
try slice.append(40);
try slice.append(50);

std.debug.print("{d}\n", .{slice.len});

var it = slice.iterator();
while (it.next()) |item| {
    std.debug.print("{d}\n", .{item});
}
```
