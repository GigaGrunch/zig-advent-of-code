const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var string = std.ArrayList(u8).init(allocator);
    defer string.deinit();

    var width: usize = undefined;
    var height: usize = 0;
    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        width = line.len;
        height += 1;
        try string.appendSlice(line);
    }

    const map = Map {
        .string = string.items,
        .width = width,
        .height = height,
    };

    var start: Coord = undefined;
    for (0..height) |y| {
        for (0..width) |x| {
            if (map.at(x, y) == 'S') {
                start = .{ .x = x, .y = y };
            }
        }
    }

    std.debug.print("{}\n", .{start});

    return 0;
}

const Coord = struct {
    x: usize,
    y: usize,
};

const Map = struct {
    string: []const u8,
    width: usize,
    height: usize,

    fn at(self: Map, x: usize, y: usize) u8 {
        return self.string[y * self.width + x];
    }
};

test "example01" {
    const text = @embedFile("example01.txt");
    const expected: i32 = 4;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}

test "example02" {
    const text = @embedFile("example02.txt");
    const expected: i32 = 8;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
