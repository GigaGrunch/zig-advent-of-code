const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        var line_it = utils.tokenize(line, " ");
        const springs = line_it.next().?;

        var groups_list = std.ArrayList(i32).init(allocator);
        defer groups_list.deinit();

        var groups_it = utils.tokenize(line_it.next().?, ",");
        while (groups_it.next()) |group_string| {
            const group = try utils.parseInt(i32, group_string);
            try groups_list.append(group);
        }

        const groups = groups_list.items;

        std.debug.print("{s} {any}\n", .{ springs, groups });

        _ = findMatches(springs, groups);
    }

    return 0;
}

fn findMatches(springs: []const u8, groups: []const i32) i32 {
    var matches: i32 = 0;

    const group = groups[0];
    const group_length: usize = @intCast(group);
    outer: for (0..springs.len - group_length) |i| {
        const test_group = springs[i .. i + group_length];
        for (test_group) |char| {
            if (char == '.') continue :outer;
        }

        if (i + group_length < springs.len) {
            if (springs[i + group_length] == '#') continue :outer;
        }

        std.debug.print("found {d} group at {d}\n", .{ group, i });
    }

    return matches;
}

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 21;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
