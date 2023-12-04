const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var visited = std.ArrayList(Pos).init(allocator);
    defer visited.deinit();

    var pos = Pos{ .x = 0, .y = 0 };
    try visited.append(pos);

    for (text) |char| {
        switch (char) {
            '<' => pos.x -= 1,
            '>' => pos.x += 1,
            '^' => pos.y += 1,
            'v' => pos.y -= 1,
            else => unreachable,
        }

        if (!utils.contains(visited.items, pos)) {
            try visited.append(pos);
        }
    }

    return @as(i32, @intCast(visited.items.len));
}

const Pos = struct {
    x: i32,
    y: i32,
};

test ">" {
    try runTest(">", 2);
}
test "^>v<" {
    try runTest("^>v<", 4);
}
test "^v^v^v^v^v" {
    try runTest("^v^v^v^v^v", 2);
}

fn runTest(text: []const u8, expected: i32) !void {
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
