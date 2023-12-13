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
        var lines = std.ArrayList([]u8).init(allocator);
        defer {
            for (lines.items) |line| allocator.free(line);
            lines.deinit();
        }

        var lines_it = utils.tokenize(pattern, "\r\n");
        while (lines_it.next()) |src_line| {
            var line = try allocator.alloc(u8, src_line.len);
            std.mem.copy(u8, line, src_line);
            try lines.append(line);
        }

        const original_vertical_reflection_line = try findVerticalReflectionLine(lines.items, allocator);
        const original_horizontal_reflection_line = try findHorizontalReflectionLine(lines.items, allocator);

        outer: for (0..lines.items.len) |smudge_y| {
            for (0..lines.items[0].len) |smudge_x| {
                var smudge = &lines.items[smudge_y][smudge_x];
                flipSmudge(smudge);
                defer flipSmudge(smudge);

                if (try findVerticalReflectionLine(lines.items, allocator)) |vertical_line| {
                    if (vertical_line != original_vertical_reflection_line) {
                        sum += @intCast(vertical_line);
                        break :outer;
                    }
                }

                if (try findHorizontalReflectionLine(lines.items, allocator)) |horizontal_line| {
                    if (horizontal_line != original_horizontal_reflection_line) {
                        sum += @intCast(100 * horizontal_line);
                        break :outer;
                    }
                }
            }
        }
    }

    return sum;
}

fn findVerticalReflectionLine(lines: []const []const u8, allocator: std.mem.Allocator) !?usize {
    var vertical_line_candidates = std.ArrayList(bool).init(allocator);
    defer vertical_line_candidates.deinit();
    try vertical_line_candidates.append(false);

    for (lines) |line| {
        try updateReflectionCandidates(u8, line, &vertical_line_candidates);
    }

    if (std.mem.indexOfScalar(bool, vertical_line_candidates.items, true)) |index| {
        return index;
    }

    return null;
}

fn findHorizontalReflectionLine(lines: []const []const u8, allocator: std.mem.Allocator) !?usize {
    var horizontal_line_candidates = std.ArrayList(bool).init(allocator);
    defer horizontal_line_candidates.deinit();
    try horizontal_line_candidates.append(false);

    try updateReflectionCandidates([]const u8, lines, &horizontal_line_candidates);

    if (std.mem.indexOfScalar(bool, horizontal_line_candidates.items, true)) |index| {
        return index;
    }

    return null;
}

fn flipSmudge(smudge: *u8) void {
    smudge.* = switch (smudge.*) {
        '#' => '.',
        '.' => '#',
        else => unreachable,
    };
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
    const expected: i32 = 400;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
