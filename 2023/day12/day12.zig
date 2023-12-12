const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var sum: i32 = 0;

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
        sum += findMatches(springs, groups);
    }

    return sum;
}

fn findMatches(springs: []const u8, groups: []const i32) i32 {
    var matches: i32 = 0;
    const current_group: usize = @intCast(groups[0]);
    const remaining_groups = groups[1..];
    var required_length = current_group;
    for (remaining_groups) |group| required_length += @intCast(1 + group);

    var start_index: usize = 0;
    outer: while (springs.len - start_index >= required_length) : (start_index += 1) {
        const test_group = springs[start_index .. start_index + current_group];
        for (test_group) |char| {
            if (char == '.') {
                continue :outer;
            }
        }

        if (remaining_groups.len == 0) {
            matches += 1;
            continue :outer;
        }

        if (start_index > 0 and springs[start_index - 1] == '#') {
            continue :outer;
        }

        if (springs[start_index + current_group] == '#') {
            continue :outer;
        }

        matches += findMatches(springs[start_index + current_group + 1 ..], remaining_groups);
    }

    return matches;
}

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 21;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
