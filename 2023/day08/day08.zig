const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var nodes = std.ArrayList(Node).init(allocator);
    defer nodes.deinit();

    var lines_it = utils.tokenize(text, "\r\n");
    const instructions = lines_it.next().?;
    _ = instructions;
    while (lines_it.next()) |line| {
        var line_it = utils.tokenize(line, " =(,)");
        const from = line_it.next().?;
        const left = line_it.next().?;
        const right = line_it.next().?;

        try nodes.append(.{
            .from = from,
            .left = left,
            .right = right,
        });
    }

    for (nodes.items) |node| {
        std.debug.print("{s}: <- {s}, -> {s}\n", .{ node.from, node.left, node.right });
    }

    return 0;
}

const Node = struct {
    from: []const u8,
    left: []const u8,
    right: []const u8,
};

test "example01" {
    const text = @embedFile("example01.txt");
    const expected: i32 = 2;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}

test "example02" {
    const text = @embedFile("example02.txt");
    const expected: i32 = 6;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
