const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = text;
    _ = allocator;
    return 0;
}

test "abcdef" {
    const expected: i32 = 609043;
    const result = try execute("abcdef", std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}

test "pqrstuv" {
    const expected: i32 = 1048970;
    const result = try execute("pqrstuv", std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
