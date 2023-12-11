const std = @import("std");
const utils = @import("utils");

var empty_space_size: u64 = 1_000_000;

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !u64 {
    var galaxies = std.ArrayList(Pos).init(allocator);
    var empty_rows = std.ArrayList(i32).init(allocator);
    var empty_columns = std.ArrayList(i32).init(allocator);
    defer {
        galaxies.deinit();
        empty_rows.deinit();
        empty_columns.deinit();
    }

    var width: usize = 0;
    var height: usize = 0;

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        width = line.len;
        height += 1;

        var is_empty_row = true;
        for (line, 0..) |char, x| {
            if (char == '#') {
                try galaxies.append(.{ .x = @intCast(x), .y = @intCast(height) });
                is_empty_row = false;
            }
        }

        if (is_empty_row) try empty_rows.append(@intCast(height));
    }

    for (0..width) |x| {
        if (for (galaxies.items) |pos| {
            if (pos.x == x) break false;
        } else true) {
            try empty_columns.append(@intCast(x));
        }
    }

    var sum: u64 = 0;
    for (galaxies.items, 0..) |pos_a, index_a| {
        for (galaxies.items[index_a + 1 ..]) |pos_b| {
            var path: u64 = 0;

            var x_pos = @min(pos_a.x, pos_b.x);
            while (x_pos != @max(pos_a.x, pos_b.x)) : (x_pos += 1) {
                path += if (utils.containsItem(empty_columns.items, x_pos)) empty_space_size else 1;
            }

            var y_pos = @min(pos_a.y, pos_b.y);
            while (y_pos != @max(pos_a.y, pos_b.y)) : (y_pos += 1) {
                path += if (utils.containsItem(empty_rows.items, y_pos)) empty_space_size else 1;
            }

            sum += path;
        }
    }

    return sum;
}

const Pos = struct {
    x: i32,
    y: i32,
};

test "10x" {
    empty_space_size = 10;
    const text = @embedFile("example.txt");
    const expected: u64 = 1030;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}

test "100x" {
    empty_space_size = 100;
    const text = @embedFile("example.txt");
    const expected: u64 = 8410;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
