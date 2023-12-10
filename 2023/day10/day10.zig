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
    var current_1: ?Coord = null;
    var current_2: ?Coord = null;

    outer: for (0..height) |y| {
        for (0..width) |x| {
            start = .{ .x = x, .y = y };
            if (map.at(start) == 'S') {
                if (x > 0) {
                    const left = Coord { .x = x - 1, .y = y };
                    switch (map.at(left)) {
                        '-', 'F', 'L' => {
                            if (current_1 == null) {
                                current_1 = left;
                            } else if (current_2 == null) {
                                current_2 = left;
                            }
                        },
                        else => { },
                    }
                }
                if (x < width) {
                    const right = Coord { .x = x + 1, .y = y };
                    switch (map.at(right)) {
                        '-', '7', 'J' => {
                            if (current_1 == null) {
                                current_1 = right;
                            } else if (current_2 == null) {
                                current_2 = right;
                            }
                        },
                        else => { },
                    }
                }
                if (y > 0) {
                    const up = Coord { .x = x, .y = y - 1 };
                    switch (map.at(up)) {
                        '|', 'F', '7' => {
                            if (current_1 == null) {
                                current_1 = up;
                            } else if (current_2 == null) {
                                current_2 = up;
                            }
                        },
                        else => { },
                    }
                }
                if (y < height) {
                    const down = Coord { .x = x, .y = y + 1 };
                    switch (map.at(down)) {
                        '|', 'J', 'L' => {
                            if (current_1 == null) {
                                current_1 = down;
                            } else if (current_2 == null) {
                                current_2 = down;
                            }
                        },
                        else => { },
                    }
                }

                break :outer;
            }
        }
    }

    std.debug.assert(current_1 != null and current_2 != null);

    var visited = std.ArrayList(Coord).init(allocator);
    defer visited.deinit();

    try visited.append(start);

    while (current_1 != null or current_2 != null) {
        if (current_1) |c_1| {
            try visited.append(c_1);
            current_1 = null;
            const connections = map.findConnections(c_1);
            if (!utils.containsItem(visited.items, connections._1)) {
                current_1 = connections._1;
            }
            else if (!utils.containsItem(visited.items, connections._2)) {
                current_1 = connections._2;
            }
        }
        if (current_2) |c_2| {
            try visited.append(c_2);
            current_2 = null;
            const connections = map.findConnections(c_2);
            if (!utils.containsItem(visited.items, connections._1)) {
                current_2 = connections._1;
            }
            else if (!utils.containsItem(visited.items, connections._2)) {
                current_2 = connections._2;
            }
        }
    }

    const loop_length: i32 = @intCast(visited.items.len);
    const farthest_distance = @divTrunc(loop_length, 2);
    return farthest_distance;
}

const Coord = struct {
    x: usize,
    y: usize,
};

const Map = struct {
    string: []const u8,
    width: usize,
    height: usize,

    fn at(self: Map, coord: Coord) u8 {
        return self.string[coord.y * self.width + coord.x];
    }

    fn findConnections(self: Map, coord: Coord) struct { _1: Coord, _2: Coord, } {
        return switch (self.at(coord)) {
            '|' => .{ ._1 = .{ .x = coord.x, .y = coord.y - 1 }, ._2 = .{ .x = coord.x, .y = coord.y + 1 } },
            '-' => .{ ._1 = .{ .x = coord.x - 1, .y = coord.y }, ._2 = .{ .x = coord.x + 1, .y = coord.y } },
            'F' => .{ ._1 = .{ .x = coord.x, .y = coord.y + 1 }, ._2 = .{ .x = coord.x + 1, .y = coord.y } },
            'J' => .{ ._1 = .{ .x = coord.x - 1, .y = coord.y }, ._2 = .{ .x = coord.x, .y = coord.y - 1 } },
            '7' => .{ ._1 = .{ .x = coord.x - 1, .y = coord.y }, ._2 = .{ .x = coord.x, .y = coord.y + 1 } },
            'L' => .{ ._1 = .{ .x = coord.x, .y = coord.y - 1 }, ._2 = .{ .x = coord.x + 1, .y = coord.y } },
            else => unreachable,
        };
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
