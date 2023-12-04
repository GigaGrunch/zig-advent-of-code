const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = allocator;
    _ = text;
    return 0;
}

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
