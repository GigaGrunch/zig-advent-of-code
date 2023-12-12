const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

var known_springs: std.ArrayList([]const u8) = undefined;
var known_groups: std.ArrayList([]const i32) = undefined;
var known_matches: std.ArrayList(u64) = undefined;

fn execute(text: []const u8, allocator: std.mem.Allocator) !u64 {
    var sum: u64 = 0;

    var springs_list = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer {
        for (springs_list.items) |list| list.deinit();
        springs_list.deinit();
    }
    var groups_list = std.ArrayList(std.ArrayList(i32)).init(allocator);
    defer {
        for (groups_list.items) |list| list.deinit();
        groups_list.deinit();
    }

    known_springs = @TypeOf(known_springs).init(allocator);
    defer known_springs.deinit();
    known_groups = @TypeOf(known_groups).init(allocator);
    defer known_groups.deinit();
    known_matches = @TypeOf(known_matches).init(allocator);
    defer known_matches.deinit();

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        var line_it = utils.tokenize(line, " ");
        const springs = line_it.next().?;

        var groups = std.ArrayList(i32).init(allocator);
        defer groups.deinit();

        var groups_it = utils.tokenize(line_it.next().?, ",");
        while (groups_it.next()) |group_string| {
            const group = try utils.parseInt(i32, group_string);
            try groups.append(group);
        }

        try springs_list.append(std.ArrayList(u8).init(allocator));
        var unfolded_springs = &springs_list.items[springs_list.items.len - 1];

        try groups_list.append(std.ArrayList(i32).init(allocator));
        var unfolded_groups = &groups_list.items[groups_list.items.len - 1];

        for (0..5) |i| {
            if (i > 0) try unfolded_springs.append('?');
            try unfolded_springs.appendSlice(springs);
            try unfolded_groups.appendSlice(groups.items);
        }

        const matches = try findMatches(unfolded_springs.items, unfolded_groups.items);
        sum += matches;
    }

    return sum;
}

fn findCachedResult(springs: []const u8, groups: []const i32) ?u64 {
    for (known_springs.items, 0..) |known_s, index| {
        if (std.meta.eql(springs, known_s)) {
            const known_g = known_groups.items[index];
            if (std.meta.eql(groups, known_g)) {
                const known_m = known_matches.items[index];
                return known_m;
            }
        }
    }
    return null;
}

fn storeResult(springs: []const u8, groups: []const i32, matches: u64) !void {
    try known_springs.append(springs);
    try known_groups.append(groups);
    try known_matches.append(matches);
}

fn findMatches(springs: []const u8, groups: []const i32) !u64 {
    if (findCachedResult(springs, groups)) |cached| {
        return cached;
    }

    var matches: u64 = 0;
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

        for (springs[0..start_index]) |char| {
            if (char == '#') {
                continue :outer;
            }
        }

        if (remaining_groups.len == 0) {
            for (springs[start_index + current_group ..]) |char| {
                if (char == '#') {
                    continue :outer;
                }
            }

            matches += 1;
            continue :outer;
        }

        if (springs[start_index + current_group] == '#') {
            continue :outer;
        }

        matches += try findMatches(springs[start_index + current_group + 1 ..], remaining_groups);
    }

    try storeResult(springs, groups, matches);

    return matches;
}

test {
    const text = @embedFile("example.txt");
    const expected: u64 = 525152;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
