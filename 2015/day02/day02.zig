const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = allocator;
    _ = text;
    return 0;
}

test "2x3x4" {
    const expected: i32 = 58;
    const result = try execute("2x3x4", std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}

test "1x1x10" {
    const expected: i32 = 43;
    const result = try execute("1x1x10", std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
