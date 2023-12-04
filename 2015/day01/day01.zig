const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = allocator;
    var level: i32 = 0;

    for (text, 0..) |char, i| {
        switch (char) {
            '(' => level += 1,
            ')' => level -= 1,
            else => unreachable,
        }

        if (level == -1) return @as(i32, @intCast(i + 1));
    }

    unreachable;
}

test {
    const inputs: []const []const u8 = &.{
        ")",
        "()())",
    };
    const expected_results: []const i32 = &.{
        1,
        5,
    };

    for (inputs, expected_results) |input, expected| {
        const result = try execute(input, std.testing.allocator);
        try std.testing.expectEqual(expected, result);
    }
}
