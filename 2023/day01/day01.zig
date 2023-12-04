const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = allocator;
    var sum: i32 = 0;

    var lines = std.mem.tokenizeAny(u8, text, "\r\n");
    while (lines.next()) |line| {
        var first_digit: ?i32 = null;
        var last_digit: ?i32 = null;
        for (0..line.len) |i| {
            if (getDigit(line[i..])) |digit| {
                if (first_digit == null) first_digit = digit;
                last_digit = digit;
            }
        }

        sum += first_digit.? * 10 + last_digit.?;
    }

    return sum;
}

fn getDigit(string: []const u8) ?u8 {
    if (startsWith(string, "zero")) return 0;
    if (startsWith(string, "one")) return 1;
    if (startsWith(string, "two")) return 2;
    if (startsWith(string, "three")) return 3;
    if (startsWith(string, "four")) return 4;
    if (startsWith(string, "five")) return 5;
    if (startsWith(string, "six")) return 6;
    if (startsWith(string, "seven")) return 7;
    if (startsWith(string, "eight")) return 8;
    if (startsWith(string, "nine")) return 9;

    return switch (string[0]) {
        '0'...'9' => string[0] - '0',
        else => null,
    };
}

fn startsWith(a: []const u8, b: []const u8) bool {
    return std.mem.startsWith(u8, a, b);
}

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 281;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
