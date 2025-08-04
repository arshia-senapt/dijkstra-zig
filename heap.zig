const std = @import("std");

pub const HeapNode = struct {
    index: usize,
    priority: usize,
};

pub const Heap = struct {
    totalNodes: usize,
    maxNodes: usize,
    nodes: []HeapNode,
};

var gHeap: ?*Heap = null;

pub fn createHeap(allocator: *const std.mem.Allocator, maxNodes: usize) !void {
    const heap = try allocator.create(Heap);
    const nodes = try allocator.alloc(HeapNode, @intCast(maxNodes + 1));
    heap.* = Heap{
        .totalNodes = 0,
        .maxNodes = maxNodes,
        .nodes = nodes,
    };
    gHeap = heap;
}

pub fn destroyHeap(allocator: *const std.mem.Allocator) void {
    if (gHeap != null) {
        allocator.free(gHeap.?.nodes);
        allocator.destroy(gHeap.?);
        gHeap = null;
    }
}

pub fn addNode(index: usize, priority: usize) !void {
    const heap = gHeap orelse return error.UninitializedHeap;

    if (heap.totalNodes >= heap.maxNodes) return error.HeapFull;

    const node = HeapNode{
        .index = index,
        .priority = priority,
    };

    heap.totalNodes += 1;
    heap.nodes[heap.totalNodes] = node;

    try upheap();
}

fn swapNodes(i: usize, j: usize) void {
    const heap = gHeap orelse return;
    const temp = heap.nodes[i];
    heap.nodes[i] = heap.nodes[j];
    heap.nodes[j] = temp;
}

pub fn upheap() !void {
    const heap = gHeap orelse return error.UninitializedHeap;

    if (heap.totalNodes == 1) return;

    var currentIndex: usize = heap.totalNodes;
    var parentIndex: usize = currentIndex / 2;

    while (parentIndex != 0 and heap.nodes[parentIndex].priority > heap.nodes[currentIndex].priority) {
        swapNodes(currentIndex, parentIndex);
        currentIndex = parentIndex;
        parentIndex = currentIndex / 2;
    }
}

pub fn removeTop() !HeapNode {
    const heap = gHeap orelse return error.UninitializedHeap;

    if (heap.totalNodes == 0) return error.HeapEmpty;

    const rootNode = heap.nodes[1];
    heap.nodes[1] = heap.nodes[heap.totalNodes];
    heap.totalNodes -= 1;

    try downheap();

    return rootNode;
}

pub fn downheap() !void {
    const heap = gHeap orelse return error.UninitializedHeap;

    var currentIndex: usize = 1;

    while (true) {
        const left = currentIndex * 2;
        const right = left + 1;
        var smallest = currentIndex;

        if (left <= heap.totalNodes and heap.nodes[left].priority < heap.nodes[smallest].priority) {
            smallest = left;
        }

        if (right <= heap.totalNodes and heap.nodes[right].priority < heap.nodes[smallest].priority) {
            smallest = right;
        }

        if (smallest == currentIndex) break;

        swapNodes(currentIndex, smallest);
        currentIndex = smallest;
    }
}

pub fn decreasePriority(index: usize, newPriority: usize) !void {
    const heap = gHeap orelse return error.UninitializedHeap;

    var indexOfNode: ?usize = null;
    for (1..heap.totalNodes + 1) |i| {
        if (heap.nodes[i].index == index) {
            indexOfNode = i;
            break;
        }
    }
    if (indexOfNode == null) return error.NodeNotFound;

    const currentPriority: usize = heap.nodes[indexOfNode.?].priority;

    if (newPriority >= currentPriority) {
        return error.PriorityChangeNotRequired;
    }

    heap.nodes[indexOfNode.?].priority = newPriority;

    var currentIndex: usize = indexOfNode.?;
    var parentIndex: usize = currentIndex / 2;

    while (parentIndex > 0 and heap.nodes[parentIndex].priority > heap.nodes[currentIndex].priority) {
        swapNodes(currentIndex, parentIndex);
        currentIndex = parentIndex;
        parentIndex = currentIndex / 2;
    }
}

pub fn printHeap() void {
    const heap = gHeap;
    if (heap == null) {
        std.debug.print("Heap not initialized\n", .{});
        return;
    }
    if (heap.?.totalNodes == 0) {
        std.debug.print("Heap is empty\n", .{});
        return;
    }
    std.debug.print("Current heap nodes:\n", .{});
    for (1..heap.?.totalNodes + 1) |i| {
        const node = heap.?.nodes[i];
        std.debug.print("Node {}: index={}, priority={}\n", .{i, node.index, node.priority});
    }
}

