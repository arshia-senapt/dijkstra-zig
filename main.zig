const std = @import("std");
const parser = @import("parser.zig");
const graph = @import("graph.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    try parser.parseGraphFromFile(&allocator, "data/graph.gx");

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Graph initialised and populated successfully.\n", .{});

    try graph.printGraph(std.io.getStdOut().writer());

}
