const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var map_list = std.ArrayList(i32).init(allocator);
    defer map_list.deinit();
    height = 0;

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        height += 1;

        for (line) |char| {
            try map_list.append(char - '0');
        }
    }

    map = map_list.items;
    width = map.len / height;

    for (0..height) |y| {
        const start = y * width;
        const end = start + width;
        std.debug.print("{any}\n", .{map[start..end]});
    }

    var frontier = std.ArrayList(State).init(allocator);
    defer frontier.deinit();

    var lowest_cost: i32 = std.math.maxInt(i32);
    try frontier.append(.{
        .x = 0,
        .y = 0,
        .run_length = 0,
        .cost = 0,
        .dir = .Right,
    });
    try frontier.append(.{
        .x = 0,
        .y = 0,
        .run_length = 0,
        .cost = 0,
        .dir = .Down,
    });

    while (frontier.items.len > 0) {
        var state = frontier.pop();
        std.debug.print("{}\n", .{state});
    }

    return lowest_cost;
}

var map: []const i32 = undefined;
var width: usize = undefined;
var height: usize = undefined;

const State = struct {
    x: usize,
    y: usize,
    run_length: i32,
    cost: i32,
    dir: Direction,
};

const Direction = enum {
    Up,
    Down,
    Left,
    Right,
};

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 102;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
