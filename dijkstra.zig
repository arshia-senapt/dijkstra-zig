const std = @import("std");
const graph = @import("graph.zig");
const heap = @import("heap.zig");

pub fn dijkstra(myGraphOpt: ?graph.Graph, startNodeIndex: usize, endNodeIndex: usize) !void {
    var allocator = std.heap.page_allocator;
    const myGraph = myGraphOpt orelse return error.UninitializedGraph;

    if (startNodeIndex < 1) return error.InvalidStartIndex;
    if (endNodeIndex > myGraph.maxSize) return error.InvalidEndIndex;

    for (myGraph.nodes[1..myGraph.maxSize + 1]) |*node| {
        node.distanceFromStart = std.math.maxInt(usize);
        node.visited = false;
        node.pathVia = 0;
    }
    myGraph.nodes[startNodeIndex].distanceFromStart = 0;

    var myHeap = try heap.Heap.init(&allocator, myGraph.maxSize);
    defer myHeap.deinit();

    try myHeap.addNode(startNodeIndex, 0);

    while (myHeap.totalNodes > 0) {
        const current = try myHeap.removeTop();
        const currentIndex = current.index;
        const currentNode = &myGraph.nodes[currentIndex];

        if (currentNode.visited) continue;
        currentNode.visited = true;

        if (currentIndex == endNodeIndex) break;

        var child = currentNode.children;
        while (child) |c| : (child = c.next) {
            const neighbor = &myGraph.nodes[c.index];
            if (neighbor.visited) continue;

            const newDist = currentNode.distanceFromStart + c.distance;
            if (newDist < neighbor.distanceFromStart) {
                neighbor.distanceFromStart = newDist;
                neighbor.pathVia = currentIndex;
                try myHeap.addNode(c.index, newDist);
            }
        }
    }

    if (!myGraph.nodes[endNodeIndex].visited) {
        std.debug.print(
            "Node {d} ({s}) cannot be reached from Node {d} ({s})\n",
            .{
                endNodeIndex, myGraph.nodes[endNodeIndex].name,
                startNodeIndex, myGraph.nodes[startNodeIndex].name
            },
        );
        return;
    }

    var path = std.ArrayList(usize).init(allocator);
    defer path.deinit();

    var currentNode = endNodeIndex;
    while (true) {
        try path.append(currentNode);
        const previousNode = myGraph.nodes[currentNode].pathVia;
        if (previousNode == 0) break;
        currentNode = previousNode;
    }

    var j: usize = path.items.len;
    while (j > 0) : (j -= 1) {
        const nodeIndex = path.items[j - 1];
        std.debug.print("{s}", .{myGraph.nodes[nodeIndex].name});
        if (j > 1) {
            std.debug.print(" -> ", .{});
        } else {
            std.debug.print("\n", .{});
        }
    }

    std.debug.print("Total distance: {d}\n", .{myGraph.nodes[endNodeIndex].distanceFromStart});
}
