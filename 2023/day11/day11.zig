const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
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

    std.debug.print("width: {d}, height: {d}\n", .{ width, height });
    std.debug.print("galaxies: ", .{});
    for (galaxies.items) |pos| std.debug.print("({d},{d}) ", .{ pos.x, pos.y });
    std.debug.print("\n", .{});
    std.debug.print("empty rows: {any}\n", .{empty_rows.items});
    std.debug.print("empty columns: {any}\n", .{empty_columns.items});

    return 0;
}

const Pos = struct {
    x: i32,
    y: i32,
};

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 374;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
