const std = @import("std");
const graph = @import("graph.zig");

pub fn parseGraphFromFile(allocator: std.mem.Allocator, filename: []const u8) !?graph.Graph {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const reader = file.reader();
    var buffered = std.io.bufferedReader(reader);
    var lineStream = buffered.reader();

    var buffer: [256]u8 = undefined;
    var myGraph: ?graph.Graph = null;

    while (try lineStream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r\n");
        if (std.mem.startsWith(u8, trimmed, "MAX")) {
            var it = std.mem.tokenizeScalar(u8, trimmed, ' ');
            _ = it.next();
            const maxSize = try std.fmt.parseInt(usize, it.next().?, 10);
            myGraph = try graph.Graph.init(allocator, maxSize);
        } else if (std.mem.startsWith(u8, trimmed, "NODE")) {
            var it = std.mem.tokenizeScalar(u8, trimmed, ' ');
            _ = it.next();
            const index = try std.fmt.parseInt(usize, it.next().?, 10);
            const name = it.next().?;
            try myGraph.?.insertGraphNode(index, name);
        } else if (std.mem.startsWith(u8, trimmed, "EDGE")) {
            var it = std.mem.tokenizeScalar(u8, trimmed, ' ');
            _ = it.next();
            const source = try std.fmt.parseInt(usize, it.next().?, 10);
            const target = try std.fmt.parseInt(usize, it.next().?, 10);
            const distance = try std.fmt.parseInt(usize, it.next().?, 10);
            try myGraph.?.insertGraphLink(source, target, distance);
        }
    }
    return myGraph;
}
