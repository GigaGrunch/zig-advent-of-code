const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var visited = std.ArrayList(Pos).init(allocator);
    defer visited.deinit();

    var santa_pos = Pos{ .x = 0, .y = 0 };
    var robot_pos = Pos{ .x = 0, .y = 0 };
    try visited.append(santa_pos);

    var santa_is_next = true;
    for (text) |char| {
        var ptr = if (santa_is_next) &santa_pos else &robot_pos;
        switch (char) {
            '<' => ptr.*.x -= 1,
            '>' => ptr.*.x += 1,
            '^' => ptr.*.y += 1,
            'v' => ptr.*.y -= 1,
            else => unreachable,
        }

        if (!utils.containsItem(visited.items, ptr.*)) {
            try visited.append(ptr.*);
        }

        santa_is_next = !santa_is_next;
    }

    return @as(i32, @intCast(visited.items.len));
}

const Pos = struct {
    x: i32,
    y: i32,
};

test "^v" {
    try runTest("^v", 3);
}
test "^>v<" {
    try runTest("^>v<", 3);
}
test "^v^v^v^v^v" {
    try runTest("^v^v^v^v^v", 11);
}

fn runTest(text: []const u8, expected: i32) !void {
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
