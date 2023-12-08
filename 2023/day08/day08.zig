const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var string_nodes = std.ArrayList(StringNode).init(allocator);
    defer string_nodes.deinit();

    var nodes = std.ArrayList(Node).init(allocator);
    defer nodes.deinit();

    var current = std.ArrayList(*Node).init(allocator);
    defer current.deinit();

    var lines_it = utils.tokenize(text, "\r\n");
    const instructions = lines_it.next().?;
    while (lines_it.next()) |line| {
        var line_it = utils.tokenize(line, " =(,)");
        const from = line_it.next().?;
        const left = line_it.next().?;
        const right = line_it.next().?;

        try string_nodes.append(.{
            .from = from,
            .left = left,
            .right = right,
        });
        try nodes.append(.{
            .left = undefined,
            .right = undefined,
            .is_goal = from[2] == 'Z',
        });
    }

    for (string_nodes.items, nodes.items) |string_node, *node| {
        for (string_nodes.items, 0..) |other, other_i| {
            if (utils.streql(string_node.left, other.from)) node.left = &nodes.items[other_i];
            if (utils.streql(string_node.right, other.from)) node.right = &nodes.items[other_i];
        }

        if (string_node.from[2] == 'A') try current.append(node);
    }

    var steps: i32 = 0;
    outer: while (true) {
        for (instructions) |instruction| {
            steps += 1;

            var all_are_goals = true;

            for (current.items) |*node| {
                node.* = switch (instruction) {
                    'L' => node.*.left,
                    'R' => node.*.right,
                    else => unreachable,
                };

                if (!node.*.is_goal) all_are_goals = false;
            }

            if (all_are_goals) break :outer;
        }
    }

    return steps;
}

const StringNode = struct {
    from: []const u8,
    left: []const u8,
    right: []const u8,
};

const Node = struct {
    left: *Node,
    right: *Node,
    is_goal: bool,
};

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 6;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
