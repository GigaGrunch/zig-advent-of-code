const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = allocator;

    var nice_count: i32 = 0;

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        if (isNice(line)) nice_count += 1;
    }

    return nice_count;
}

fn isNice(text: []const u8) bool {
    var vowel_count: i32 = 0;
    var double_count: i32 = 0;

    for (0..text.len) |i| {
        switch (text[i]) {
            'a', 'e', 'i', 'o', 'u' => vowel_count += 1,
            else => {},
        }

        if (i > 0) {
            const pair = text[i - 1 .. i + 1];

            if (utils.streql(pair, "ab")) return false;
            if (utils.streql(pair, "cd")) return false;
            if (utils.streql(pair, "pq")) return false;
            if (utils.streql(pair, "xy")) return false;

            if (pair[0] == pair[1]) double_count += 1;
        }
    }

    return vowel_count >= 3 and double_count >= 1;
}

test "qjhvhtzxzqqjkmpb" {
    const expected: i32 = 1;
    const result = try execute("qjhvhtzxzqqjkmpb", std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}

test "xxyxx" {
    const expected: i32 = 1;
    const result = try execute("xxyxx", std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}

test "uurcxstgmygtbstg" {
    const expected: i32 = 0;
    const result = try execute("uurcxstgmygtbstg", std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}

test "ieodomkazucvgmuy" {
    const expected: i32 = 0;
    const result = try execute("ieodomkazucvgmuy", std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
