const std = @import("std");

pub const ChildNode = struct {
    index: usize,
    distance: usize,
    next: ?*ChildNode = null,
};

pub const GraphNode = struct {
    name: []const u8,
    children: ?*ChildNode = null,
    visted: bool,
    distanceFromStart: usize,
    pathVia: usize,
};

pub const Graph = struct {
    maxSize: usize,
    nodes: []GraphNode,
};

var gGraph: ?*Graph = null;

pub fn initialiseGraph(allocator: *const std.mem.Allocator, maxSize: usize) !void {
    const graph = try allocator.create(Graph);
    const nodes = try allocator.alloc(GraphNode, @intCast(maxSize + 1));
    graph.* = Graph{
        .maxSize = maxSize,
        .nodes = nodes,
    };
    gGraph = graph;
}

pub fn destroyGraph(allocator: *const std.mem.Allocator) void {
    if (gGraph != null) {
        allocator.free(gGraph.?.nodes);
        allocator.free(gGraph.?);
        gGraph = null;
    }
}

pub fn insertGraphNode(index: usize, name: []const u8) !void {
    const graph = gGraph orelse return error.UninitializedGraph;
    graph.nodes[index] = GraphNode{
        .name = name,
        .children = null,
        .visted = false,
        .distanceFromStart = std.math.maxInt(usize),
        .pathVia = 0,
    };
}

pub fn insertGraphLink(allocator: *const std.mem.Allocator, source: usize, target: usize, distance: usize) !void {
    const graph = gGraph orelse return error.UninitializedGraph;
    const newChild = try allocator.create(ChildNode);
    newChild.* = ChildNode{
        .index = target,
        .distance = distance,
        .next = graph.nodes[source].children,
    };
    graph.nodes[source].children = newChild;
}

pub fn printGraph(stdout: anytype) !void {
    const graph = gGraph orelse return error.UninitializedGraph;

    var i: usize = 1;
    while (i <= graph.maxSize) : (i += 1) {
        const node = &graph.nodes[i];
        try stdout.print("Node {d}: {s}\n", .{ i, node.name });

        var child = node.children;
        while (child) |c| {
            try stdout.print("  -> {d} (distance: {d})\n", .{ c.index, c.distance });
            child = c.next;
        }
    }
}

