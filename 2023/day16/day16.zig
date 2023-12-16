const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !usize {
    var energized = std.ArrayList(usize).init(allocator);
    var frontier = std.ArrayList(Beam).init(allocator);
    var string = std.ArrayList(u8).init(allocator);
    defer {
        energized.deinit();
        frontier.deinit();
        string.deinit();
    }

    var map = Map {
        .string = undefined,
        .width = undefined,
        .height = 0,
    };

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        try string.appendSlice(line);
        map.width = line.len;
        map.height += 1;
    }
    map.string = string.items;

    map.print();

    return energized.items.len;
}

const Beam = struct {
    x: usize,
    y: usize,
    direction: enum { Right, Left, Up, Down },
};

const Map = struct {
    string: []const u8,
    width: usize,
    height: usize,

    fn print(map: Map) void {
        for (0..map.height) |y| {
            const start = y * map.width;
            const end = start + map.width;
            std.debug.print("{s}\n", .{map.string[start..end]});
        }
    }
};

test {
    const text = @embedFile("example.txt");
    const expected: usize = 46;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
