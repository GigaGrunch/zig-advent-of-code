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

    var current: *Node = undefined;
    var goal: *Node = undefined;

    for (nodes.items) |*node| {
        if (utils.streql(node.from, "AAA")) current = node;
        if (utils.streql(node.from, "ZZZ")) goal = node;
    }

    var steps: i32 = 0;
    while (current != goal) {
        for (instructions) |instruction| {
            steps += 1;

            const next = switch (instruction) {
                'L' => current.left,
                'R' => current.right,
                else => unreachable,
            };

            current = for (nodes.items) |*node| {
                if (utils.streql(node.from, next)) break node;
            } else unreachable;

            if (current == goal) {
                break;
            }
        }
    }

    return steps;
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
