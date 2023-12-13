const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    const empty_line = if (utils.containsString(text, "\r\n")) "\r\n\r\n" else "\n\n";

    var sum: i32 = 0;

    var patterns_it = std.mem.split(u8, text, empty_line);
    while (patterns_it.next()) |pattern| {
        var lines = std.ArrayList([]const u8).init(allocator);
        defer lines.deinit();

        var lines_it = utils.tokenize(pattern, "\r\n");
        while (lines_it.next()) |line| {
            try lines.append(line);
        }

        var horizontal_mirror_candidates = std.ArrayList(bool).init(allocator);
        defer horizontal_mirror_candidates.deinit();
        try horizontal_mirror_candidates.append(false);

        for (lines.items) |line| {
            try updateReflectionCandidates(u8, line, &horizontal_mirror_candidates);
        }

        var vertical_mirror_candidates = std.ArrayList(bool).init(allocator);
        defer vertical_mirror_candidates.deinit();
        try vertical_mirror_candidates.append(false);

        try updateReflectionCandidates([]const u8, lines.items, &vertical_mirror_candidates);

        if (std.mem.indexOfScalar(bool, horizontal_mirror_candidates.items, true)) |index| {
            sum += @intCast(index);
        } else if (std.mem.indexOfScalar(bool, vertical_mirror_candidates.items, true)) |index| {
            sum += @intCast(100 * index);
        } else {
            unreachable;
        }
    }

    return sum;
}

fn updateReflectionCandidates(comptime T: type, list: []const T, candidates: *std.ArrayList(bool)) !void {
    for (1..list.len) |i| {
        if (i == candidates.items.len) {
            try candidates.append(true);
        } else if (candidates.items[i] == false) {
            continue;
        }

        const prefix = list[0..i];
        const suffix = list[i..];

        var reverse_prefix = std.mem.reverseIterator(prefix);
        const are_equal = for (suffix) |s| {
            if (reverse_prefix.next()) |p| {
                if (T == []const u8) {
                    if (!utils.streql(s, p)) break false;
                } else if (T == u8) {
                    if (s != p) break false;
                } else {
                    @compileError("not defined for this type");
                }
            }
        } else true;

        if (!are_equal) {
            candidates.items[i] = false;
        }
    }
}

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 405;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
