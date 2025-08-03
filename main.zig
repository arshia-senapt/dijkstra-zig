const std = @import("std");
const heap = @import("heap.zig");

pub fn main() !void {
    var allocator = std.heap.page_allocator;

    try heap.createHeap(&allocator, 15);
    defer heap.destroyHeap(&allocator);

    try heap.addNode(10, 100);
    try heap.addNode(20, 80);
    try heap.addNode(30, 90);
    try heap.addNode(40, 70);
    try heap.addNode(50, 60);

    std.debug.print("Initial heap:\n", .{});
    heap.printHeap();

    try heap.decreasePriority(30, 50);
    try heap.decreasePriority(50, 10);
    std.debug.print("\nHeap after decreasing priorities:\n", .{});
    heap.printHeap();

    while (true) {
        const maybeNode = heap.removeTop();
        if (maybeNode) |topNode| {
            std.debug.print("\nRemoved top node: index={}, priority={}\n", .{topNode.index, topNode.priority});
            std.debug.print("Heap now:\n", .{});
            heap.printHeap();
        } else |err| {
            if (err == error.HeapEmpty) break;
            return err;
        }
    }
}
