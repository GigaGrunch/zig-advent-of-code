const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    const empty_line = if (utils.containsString(text, "\r\n")) "\r\n\r\n" else "\n\n";

    var patterns_it = std.mem.split(u8, text, empty_line);
    while (patterns_it.next()) |pattern| {
        var horizontal_mirror_candidates = std.ArrayList(bool).init(allocator);
        defer horizontal_mirror_candidates.deinit();
        try horizontal_mirror_candidates.append(false);

        var lines_it = utils.tokenize(pattern, "\r\n");
        while (lines_it.next()) |line| {
            for (1..line.len) |i| {
                if (i == horizontal_mirror_candidates.items.len) {
                    try horizontal_mirror_candidates.append(true);
                } else if (horizontal_mirror_candidates.items[i] == false) {
                    continue;
                }

                const left = line[0..i];
                const right = line[i..];

                var reverse_left = std.mem.reverseIterator(left);
                const are_equal = for (right) |r| {
                    if (reverse_left.next()) |l| {
                        if (l != r) {
                            break false;
                        }
                    }
                } else true;

                if (!are_equal) {
                    horizontal_mirror_candidates.items[i] = false;
                }
            }
        }

        if (std.mem.indexOfScalar(bool, horizontal_mirror_candidates.items, true)) |index| {
            std.debug.print("columns left of vertical line: {d}\n", .{index});
        } else {
            std.debug.print("no vertical line\n", .{});
        }
    }

    return 0;
}

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 405;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
