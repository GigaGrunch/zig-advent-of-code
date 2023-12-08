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

    var current = std.ArrayList(*Node).init(allocator);
    defer current.deinit();

    for (nodes.items) |*node| {
        if (node.from[2] == 'A') try current.append(node);
    }

    var steps: i32 = 0;
    outer: while (true) {
        for (instructions) |instruction| {
            steps += 1;

            var all_are_goals = true;

            for (current.items) |*node| {
                const next = switch (instruction) {
                    'L' => node.*.left,
                    'R' => node.*.right,
                    else => unreachable,
                };

                node.* = for (nodes.items) |*other| {
                    if (utils.streql(other.from, next)) break other;
                } else unreachable;

                if (node.*.from[2] != 'Z') all_are_goals = false;
            }

            if (all_are_goals) break :outer;
        }
    }

    return steps;
}

const Node = struct {
    from: []const u8,
    left: []const u8,
    right: []const u8,
};

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 6;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
