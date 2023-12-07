const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var nice_count: i32 = 0;

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        if (try isNice(line, allocator)) nice_count += 1;
    }

    return nice_count;
}

fn isNice(text: []const u8, allocator: std.mem.Allocator) !bool {
    var has_double_pair = false;
    var has_distant_pair = false;
    var pairs = std.ArrayList([]const u8).init(allocator);
    defer pairs.deinit();

    for (0..text.len - 1) |i| {
        if (!has_double_pair) {
            const pair = text[i .. i + 2];
            for (pairs.items) |other| {
                if (utils.streql(pair, other) and &pair[0] != &other[1]) {
                    has_double_pair = true;
                    break;
                }
            }
            try pairs.append(pair);
        }

        if (!has_distant_pair and i < text.len - 2) {
            const char = text[i];
            const other = text[i + 2];
            if (char == other) {
                has_distant_pair = true;
            }
        }
    }

    return has_double_pair and has_distant_pair;
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
