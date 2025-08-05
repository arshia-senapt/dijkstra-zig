const std = @import("std");
const graph = @import("graph.zig");

pub fn parseGraphFromFile(allocator: std.mem.Allocator, filename: []const u8) !?graph.Graph {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const reader = file.reader();
    var buffered = std.io.bufferedReader(reader);
    var lineStream = buffered.reader();

    var lineBuffer: [256]u8 = undefined;
    var graphOpt: ?graph.Graph = null;

    while (true) {
        const line = try lineStream.readUntilDelimiterOrEof(&lineBuffer, '\n');
        if (line == null) break;

        const trimmed = std.mem.trim(u8, line.?, " \t\r\n");
        if (trimmed.len == 0) continue;

        if (std.mem.startsWith(u8, trimmed, "MAX")) {
            var it = std.mem.tokenizeScalar(u8, trimmed, ' ');
            _ = it.next();
            const maxSizeStr = it.next() orelse return error.InvalidFormat;
            const maxSize = try std.fmt.parseInt(usize, maxSizeStr, 10);
            graphOpt = try graph.Graph.init(allocator, maxSize);

        } else if (std.mem.startsWith(u8, trimmed, "NODE")) {
            if (graphOpt == null) return error.GraphNotInitialized;

            var it = std.mem.tokenizeScalar(u8, trimmed, ' ');
            _ = it.next();
            const indexStr = it.next() orelse return error.InvalidFormat;
            const index = try std.fmt.parseInt(usize, indexStr, 10);
            const name = it.next() orelse return error.InvalidFormat;
            try graphOpt.?.insertGraphNode(index, name);

        } else if (std.mem.startsWith(u8, trimmed, "EDGE")) {
            if (graphOpt == null) return error.GraphNotInitialized;

            var it = std.mem.tokenizeScalar(u8, trimmed, ' ');
            _ = it.next();
            const sourceStr = it.next() orelse return error.InvalidFormat;
            const targetStr = it.next() orelse return error.InvalidFormat;
            const distanceStr = it.next() orelse return error.InvalidFormat;

            const source = try std.fmt.parseInt(usize, sourceStr, 10);
            const target = try std.fmt.parseInt(usize, targetStr, 10);
            const distance = try std.fmt.parseInt(usize, distanceStr, 10);

            try graphOpt.?.insertGraphLink(source, target, distance);
        }
    }

    return graphOpt;
}
