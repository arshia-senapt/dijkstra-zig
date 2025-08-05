const std = @import("std");
const graph = @import("graph.zig");
const heap = @import("heap.zig");

pub fn dijkstra(myGraphOpt: ?graph.Graph, startNodeIndex: usize, endNodeIndex: usize) !void {
    var allocator = std.heap.page_allocator;
    const myGraph = myGraphOpt orelse return error.UninitializedGraph;

    if (startNodeIndex < 1) return error.InvalidStartIndex;
    if (endNodeIndex > myGraph.maxSize) return error.InvalidEndIndex;

    var i: usize = 1;
    while (i <= myGraph.maxSize) : (i += 1) {
        var node = &myGraph.nodes[i];
        node.distanceFromStart = std.math.maxInt(usize);
        node.visited = false;
        node.isInHeap = false;
        node.pathVia = 0;
    }
    myGraph.nodes[startNodeIndex].distanceFromStart = 0;

    try heap.createHeap(&allocator, myGraph.maxSize);

    try heap.addNode(startNodeIndex, 0);
    myGraph.nodes[startNodeIndex].isInHeap = true;

    const myHeap = heap.gHeap orelse return error.UninitializedHeap;

    while (myHeap.totalNodes > 0) {
        const currentNode = try heap.removeTop();
        const currentIndex = currentNode.index;
        var currentNodeRef = &myGraph.nodes[currentIndex];

        if (currentNodeRef.visited) continue;

        currentNodeRef.visited = true;
        if (currentIndex == endNodeIndex) break;

        var children = currentNodeRef.children;
        while (children) |child| {
            const neighborIndex = child.index;
            var neighborNode = &myGraph.nodes[neighborIndex];
            if (neighborNode.visited) {
                children = child.next;
                continue;
            }

            const newDistance = currentNodeRef.distanceFromStart + child.distance;
            if (newDistance < neighborNode.distanceFromStart) {
                neighborNode.distanceFromStart = newDistance;
                neighborNode.pathVia = currentIndex;

                if (neighborNode.isInHeap) {
                    try heap.decreasePriority(neighborIndex, newDistance);
                } else {
                    try heap.addNode(neighborIndex, newDistance);
                    neighborNode.isInHeap = true;
                }
            }
            children = child.next;
        }
    }

    if (!myGraph.nodes[endNodeIndex].visited) {
        std.debug.print("Node {d} ({s}) cannot be reached from Node {d} ({s})\n",
            .{endNodeIndex, myGraph.nodes[endNodeIndex].name, startNodeIndex, myGraph.nodes[startNodeIndex].name});
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
