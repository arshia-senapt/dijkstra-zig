const std = @import("std");

pub const HeapNode = struct {
    index: usize,
    priority: usize,
};

pub const Heap = struct {
    totalNodes: usize,
    maxNodes: usize,
    nodes: []HeapNode,
    allocator: *std.mem.Allocator,

    pub fn init(allocator: *std.mem.Allocator, maxNodes: usize) !Heap {
        return .{
            .totalNodes = 0,
            .maxNodes = maxNodes,
            .nodes = try allocator.alloc(HeapNode, maxNodes + 1),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Heap) void {
        self.allocator.free(self.nodes);
    }

    pub fn addNode(self: *Heap, index: usize, priority: usize) !void {
        if (self.totalNodes >= self.maxNodes) return error.HeapFull;

        self.totalNodes += 1;
        self.nodes[self.totalNodes] = HeapNode{
            .index = index,
            .priority = priority,
        };
        try self.upheap();
    }

    fn swapNodes(self: *Heap, i: usize, j: usize) void {
        const temp = self.nodes[i];
        self.nodes[i] = self.nodes[j];
        self.nodes[j] = temp;
    }

    fn upheap(self: *Heap) !void {
        if (self.totalNodes <= 1) return;

        var currentIndex = self.totalNodes;
        var parentIndex = currentIndex / 2;

        while (parentIndex != 0 and
            self.nodes[parentIndex].priority > self.nodes[currentIndex].priority)
        {
            self.swapNodes(currentIndex, parentIndex);
            currentIndex = parentIndex;
            parentIndex = currentIndex / 2;
        }
    }

    pub fn removeTop(self: *Heap) !HeapNode {
        if (self.totalNodes == 0) return error.HeapEmpty;

        const rootNode = self.nodes[1];
        self.nodes[1] = self.nodes[self.totalNodes];
        self.totalNodes -= 1;

        try self.downheap();

        return rootNode;
    }

    fn downheap(self: *Heap) !void {
        var currentIndex: usize = 1;

        while (true) {
            const left = currentIndex * 2;
            const right = left + 1;
            var smallest = currentIndex;

            if (left <= self.totalNodes and
                self.nodes[left].priority < self.nodes[smallest].priority)
                {
                    smallest = left;
                }

            if (right <= self.totalNodes and
                self.nodes[right].priority < self.nodes[smallest].priority)
                {
                    smallest = right;
                }

            if (smallest == currentIndex) break;

            self.swapNodes(currentIndex, smallest);
            currentIndex = smallest;
        }
    }

    pub fn decreasePriority(self: *Heap, index: usize, newPriority: usize) !void {
        var pos: usize = 0;

        for (1..self.totalNodes + 1) |i| {
            if (self.nodes[i].index == index) {
                pos = i;
                break;
            }
        }

        if (pos == 0) return error.NodeNotInHeap;

        if (newPriority >= self.nodes[pos].priority) return error.InvalidPriorityDecrease;

        self.nodes[pos].priority = newPriority;

        var currentIndex = pos;
        var parentIndex = currentIndex / 2;

        while (parentIndex != 0 and
            self.nodes[parentIndex].priority > self.nodes[currentIndex].priority)
        {
            const temp = self.nodes[currentIndex];
            self.nodes[currentIndex] = self.nodes[parentIndex];
            self.nodes[parentIndex] = temp;

            currentIndex = parentIndex;
            parentIndex = currentIndex / 2;
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
