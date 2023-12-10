const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = text;
    _ = allocator;
    return 0;
}

test "example01" {
    const text = @embedFile("example01.txt");
    const expected: i32 = 4;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}

test "example02" {
    const text = @embedFile("example02.txt");
    const expected: i32 = 8;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
