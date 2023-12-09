const std = @import("std");
const utils = @import("utils");
const builtin = @import("builtin");

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

    var loop_lengths = std.ArrayList(i32).init(allocator);
    defer loop_lengths.deinit();

    for (current.items) |*node| {
        var starts = std.ArrayList(*Node).init(allocator);
        defer starts.deinit();

        while (true) {
            if (std.mem.indexOfScalar(*Node, starts.items, node.*)) |start_index| {
                const end_index = starts.items.len;
                const start_step = start_index * instructions.len;
                const end_step = end_index * instructions.len;
                const steps_count = end_step - start_step;
                try loop_lengths.append(@intCast(steps_count));
                if (!builtin.is_test) {
                }
                    std.debug.print("found the loop: {d} -> {d} = {d}\n", .{start_step, end_step, steps_count});
                break;
            }

            try starts.append(node.*);

            for (instructions) |instruction| {
                node.* = switch (instruction) {
                    'L' => node.*.left,
                    'R' => node.*.right,
                    else => unreachable,
                };
            }
        }
    }

    return 0;
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
