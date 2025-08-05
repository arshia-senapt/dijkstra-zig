const std = @import("std");

pub const ChildNode = struct {
    index: usize,
    distance: usize,
    next: ?*ChildNode = null,
};

pub const GraphNode = struct {
    name: []const u8,
    children: ?*ChildNode = null,
    visited: bool,
    distanceFromStart: usize,
    pathVia: usize,

    pub fn deinit(self: *GraphNode, allocator: std.mem.Allocator) void {
        allocator.free(self.name);
        var child = self.children;
        while (child) |c| {
            const next = c.next;
            allocator.destroy(c);
            child = next;
        }
        self.children = null;
    }
};

pub const Graph = struct {
    maxSize: usize,
    nodes: []GraphNode,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, maxSize: usize) !Graph {
        const nodes = try allocator.alloc(GraphNode, @intCast(maxSize + 1));
        return .{
            .maxSize = maxSize,
            .nodes = nodes,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Graph) void {
        defer self.allocator.free(self.nodes);
        for (self.nodes) |*node| {
            node.deinit(self.allocator);
        }
    }

    pub fn insertGraphNode(self: *Graph, index: usize, name: []const u8) !void {
        self.nodes[index] = GraphNode{
            .name = try self.allocator.dupe(u8, name),
            .children = null,
            .visited = false,
            .distanceFromStart = std.math.maxInt(usize),
            .pathVia = 0,
        };
    }

    pub fn insertGraphLink(self: *Graph, source: usize, target: usize, distance: usize) !void {
        const newChild = try self.allocator.create(ChildNode);
        newChild.* = ChildNode{
            .index = target,
            .distance = distance,
            .next = self.nodes[source].children,
        };
        self.nodes[source].children = newChild;
    }

    pub fn format(self: *const Graph, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        if (fmt.len != 0) {
            std.fmt.invalidFmtError(fmt, self);
        }

        var i: usize = 1;
        while (i <= self.maxSize) : (i += 1) {
            const node = self.nodes[i];
            try writer.print("Node {d}: {s}\n", .{ i, node.name });

            var child = node.children;
            while (child) |c| {
                try writer.print("  -> {d} (distance: {d})\n", .{ c.index, c.distance });
                child = c.next;
            }
        }
    }
};

