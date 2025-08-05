const std = @import("std");
const parser = @import("parser.zig");
const graph = @import("graph.zig");
const dijkstra = @import("dijkstra.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const myGraph = try parser.parseGraphFromFile(allocator, "data/graph3.gx");

    //const stdout = std.io.getStdOut().writer();
    // if (myGraph) |_graph| {
    //     try stdout.print("Graph initialised and populated successfully.\n{any}\n", .{_graph});
    // }

    try dijkstra.dijkstra(myGraph,1, 20);

    //TODO deinit graph after everything is done

}
