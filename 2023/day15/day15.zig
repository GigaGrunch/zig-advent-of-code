const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = allocator;
    _ = text;
    return 0;
}

test "HASH" {
    const text = "HASH";
    const expected: i32 = 52;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}

test "example.txt" {
    const text = @embedFile("example.txt");
    const expected: i32 = 1320;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
