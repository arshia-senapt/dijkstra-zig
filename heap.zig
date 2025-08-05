const std = @import("std");

pub const HeapNode = struct {
    index: usize,
    priority: usize,
};

pub const Heap = struct {
    totalNodes: usize,
    maxNodes: usize,
    nodes: []HeapNode,
    index_map: []usize,
    allocator: *std.mem.Allocator,

    pub fn init(allocator: *std.mem.Allocator, maxNodes: usize) !Heap {
        return .{
            .totalNodes = 0,
            .maxNodes = maxNodes,
            .nodes = try allocator.alloc(HeapNode, maxNodes + 1),
            .index_map = try allocator.alloc(usize, maxNodes + 1),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Heap) void {
        self.allocator.free(self.nodes);
        self.allocator.free(self.index_map);
    }

    pub fn addNode(self: *Heap, index: usize, priority: usize) !void {
        if (self.totalNodes >= self.maxNodes) return error.HeapFull;

        self.totalNodes += 1;
        self.nodes[self.totalNodes] = HeapNode{
            .index = index,
            .priority = priority,
        };
        self.index_map[index] = self.totalNodes;
        try self.upheap();
    }

    fn swapNodes(self: *Heap, i: usize, j: usize) void {
        const temp = self.nodes[i];
        self.nodes[i] = self.nodes[j];
        self.nodes[j] = temp;

        self.index_map[self.nodes[i].index] = i;
        self.index_map[self.nodes[j].index] = j;
    }

    fn upheap(self: *Heap) !void {
        var currentIndex = self.totalNodes;
        while (currentIndex > 1) {
            const parentIndex = currentIndex / 2;
            if (self.nodes[parentIndex].priority <= self.nodes[currentIndex].priority) break;

            self.swapNodes(currentIndex, parentIndex);
            currentIndex = parentIndex;
        }
    }

    pub fn removeTop(self: *Heap) !HeapNode {
        if (self.totalNodes == 0) return error.HeapEmpty;

        const rootNode = self.nodes[1];
        self.index_map[rootNode.index] = 0;

        self.nodes[1] = self.nodes[self.totalNodes];
        self.index_map[self.nodes[1].index] = 1;

        self.totalNodes -= 1;
        try self.downheap(1);

        return rootNode;
    }

    fn downheap(self: *Heap, startIndex: usize) !void {
        var currentIndex = startIndex;

        while (true) {
            const left = currentIndex * 2;
            const right = left + 1;
            var smallest = currentIndex;

            if (left <= self.totalNodes and self.nodes[left].priority < self.nodes[smallest].priority) {
                smallest = left;
            }

            if (right <= self.totalNodes and self.nodes[right].priority < self.nodes[smallest].priority) {
                smallest = right;
            }

            if (smallest == currentIndex) break;

            self.swapNodes(currentIndex, smallest);
            currentIndex = smallest;
        }
    }

    pub fn decreasePriority(self: *Heap, index: usize, newPriority: usize) !void {
        const pos = self.index_map[index];
        if (pos == 0 or pos > self.totalNodes) return error.NodeNotInHeap;
        if (newPriority >= self.nodes[pos].priority) return error.InvalidPriorityDecrease;

        self.nodes[pos].priority = newPriority;

        var currentIndex = pos;
        while (currentIndex > 1) {
            const parentIndex = currentIndex / 2;
            if (self.nodes[parentIndex].priority <= self.nodes[currentIndex].priority) break;

            self.swapNodes(currentIndex, parentIndex);
            currentIndex = parentIndex;
        }
    }

    pub fn print(self: *Heap) void {
        if (self.totalNodes == 0) {
            std.debug.print("Heap is empty\n", .{});
            return;
        }
        std.debug.print("Current heap nodes:\n", .{});
        for (1..self.totalNodes + 1) |i| {
            const node = self.nodes[i];
            std.debug.print("Node {}: index={}, priority={}\n", .{i, node.index, node.priority});
        }
    }
};
