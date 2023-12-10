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

    var start_index: usize = undefined;
    var start: Coord = undefined;
    var current_1: ?Coord = null;
    var current_2: ?Coord = null;

    outer: for (0..height) |y| {
        for (0..width) |x| {
            start = .{ .x = x, .y = y };
            if (map.at(start) == 'S') {
                start_index = y * width + x;

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

    const has_up = current_1.?.y + 1 == start.y or current_2.?.y + 1 == start.y;
    const has_down = current_1.?.y == start.y + 1 or current_2.?.y == start.y + 1;
    const has_left = current_1.?.x + 1 == start.x or current_2.?.x + 1 == start.x;
    const has_right = current_1.?.x == start.x + 1 or current_2.?.x == start.x + 1;

    var inferred_start: u8 = 0;
    if (has_up and has_down) inferred_start = '|';
    if (has_up and has_left) inferred_start = 'J';
    if (has_up and has_right) inferred_start = 'L';
    if (has_down and has_left) inferred_start = '7';
    if (has_down and has_right) inferred_start = 'F';
    if (has_left and has_right) inferred_start = '-';

    std.debug.assert(inferred_start != 0);

    map.string[start_index] = inferred_start;

    var visited = std.ArrayList(Coord).init(allocator);
    defer visited.deinit();

    var sides = std.ArrayList(SideInfo).init(allocator);
    defer sides.deinit();

    try visited.append(start);
    try sides.append(.{});

    while (current_1 != null or current_2 != null) {
        if (current_1) |c_1| {
            try visited.append(c_1);
            try sides.append(.{});
            current_1 = null;
            const connections = map.findConnections(c_1);
            for (connections) |connection| {
                if (!utils.containsItem(visited.items, connection)) {
                    current_1 = connection;
                    break;
                }
            }
        }
        if (current_2) |c_2| {
            try visited.append(c_2);
            try sides.append(.{});
            current_2 = null;
            const connections = map.findConnections(c_2);
            for (connections) |connection| {
                if (!utils.containsItem(visited.items, connection)) {
                    current_2 = connection;
                    break;
                }
            }
        }
    }

    var current: Coord = undefined;
    outer: for (0..height) |y| {
        for (0..width) |x| {
            const coord = Coord { .x = x, .y = y };
            if (utils.indexOf(visited.items, coord)) |index| {
                current = coord;
                const char = map.at(coord);
                switch (char) {
                    'F' => {
                        sides.items[index].up_is_inner = false;
                        sides.items[index].left_is_inner = false;
                    },
                    else => unreachable,
                }
                break :outer;
            }
        }
    }

    while (true) {
        const current_sides = sides.items[utils.indexOf(visited.items, current).?];

        var found_other = false;
        const others = map.findConnections(current);
        for (others) |other| {
            const other_char = map.at(other);
            var other_sides = &sides.items[utils.indexOf(visited.items, other).?];
            if (other_sides.up_is_inner == null and
                other_sides.down_is_inner == null and
                other_sides.left_is_inner == null and
                other_sides.right_is_inner == null) {
                switch (other_char) {
                    '|' => {
                        if (current_sides.left_is_inner) |left_is_inner| {
                            other_sides.left_is_inner = left_is_inner;
                            other_sides.right_is_inner = !left_is_inner;
                        } else if (current_sides.right_is_inner) |right_is_inner| {
                            other_sides.right_is_inner = right_is_inner;
                            other_sides.left_is_inner = !right_is_inner;
                        }
                    },
                    '-' => {
                        if (current_sides.up_is_inner) |up_is_inner| {
                            other_sides.up_is_inner = up_is_inner;
                            other_sides.down_is_inner = !up_is_inner;
                        } else if (current_sides.down_is_inner) |down_is_inner| {
                            other_sides.down_is_inner = down_is_inner;
                            other_sides.up_is_inner = !down_is_inner;
                        }
                    },
                    'F' => {
                        if (current.x == other.x + 1) {
                            if (current_sides.up_is_inner) |up_is_inner| {
                                other_sides.up_is_inner = up_is_inner;
                                other_sides.left_is_inner = up_is_inner;
                            } else if (current_sides.down_is_inner) |down_is_inner| {
                                other_sides.up_is_inner = !down_is_inner;
                                other_sides.left_is_inner = !down_is_inner;
                            }
                        } else {
                            if (current_sides.left_is_inner) |left_is_inner| {
                                other_sides.left_is_inner = left_is_inner;
                                other_sides.up_is_inner = left_is_inner;
                            } else if (current_sides.right_is_inner) |right_is_inner| {
                                other_sides.left_is_inner = !right_is_inner;
                                other_sides.up_is_inner = !right_is_inner;
                            }
                        }
                    },
                    'L' => {
                        if (current.x == other.x + 1) {
                            if (current_sides.up_is_inner) |up_is_inner| {
                                other_sides.down_is_inner = !up_is_inner;
                                other_sides.left_is_inner = !up_is_inner;
                            } else if (current_sides.down_is_inner) |down_is_inner| {
                                other_sides.down_is_inner = down_is_inner;
                                other_sides.left_is_inner = down_is_inner;
                            }
                        } else {
                            if (current_sides.left_is_inner) |left_is_inner| {
                                other_sides.left_is_inner = left_is_inner;
                                other_sides.down_is_inner = left_is_inner;
                            } else if (current_sides.right_is_inner) |right_is_inner| {
                                other_sides.left_is_inner = !right_is_inner;
                                other_sides.down_is_inner = !right_is_inner;
                            }
                        }
                    },
                    'J' => {
                        if (current.x + 1 == other.x) {
                            if (current_sides.up_is_inner) |up_is_inner| {
                                other_sides.down_is_inner = !up_is_inner;
                                other_sides.right_is_inner = !up_is_inner;
                            } else if (current_sides.down_is_inner) |down_is_inner| {
                                other_sides.down_is_inner = down_is_inner;
                                other_sides.right_is_inner = down_is_inner;
                            }
                        } else {
                            if (current_sides.left_is_inner) |left_is_inner| {
                                other_sides.right_is_inner = !left_is_inner;
                                other_sides.down_is_inner = !left_is_inner;
                            } else if (current_sides.right_is_inner) |right_is_inner| {
                                other_sides.right_is_inner = right_is_inner;
                                other_sides.down_is_inner = right_is_inner;
                            }
                        }
                    },
                    '7' => {
                        if (current.x + 1 == other.x) {
                            if (current_sides.up_is_inner) |up_is_inner| {
                                other_sides.up_is_inner = up_is_inner;
                                other_sides.right_is_inner = up_is_inner;
                            } else if (current_sides.down_is_inner) |down_is_inner| {
                                other_sides.up_is_inner = !down_is_inner;
                                other_sides.right_is_inner = !down_is_inner;
                            }
                        } else {
                            if (current_sides.left_is_inner) |left_is_inner| {
                                other_sides.right_is_inner = !left_is_inner;
                                other_sides.up_is_inner = !left_is_inner;
                            } else if (current_sides.right_is_inner) |right_is_inner| {
                                other_sides.right_is_inner = right_is_inner;
                                other_sides.up_is_inner = right_is_inner;
                            }
                        }
                    },
                    else => unreachable,
                }

                found_other = true;
                current = other;
                break;
            }
        }

        if (!found_other) break;
    }

    var inner_count: i32 = 0;
    for (0..height) |y| {
        var is_inner = false;
        for (0..width) |x| {
            const coord = Coord { .x = x, .y = y };
            if (utils.indexOf(visited.items, coord)) |index| {
                if (sides.items[index].right_is_inner) |right_is_inner| {
                    is_inner = right_is_inner;
                }
            } else if (is_inner) {
                inner_count += 1;
            }
        }
    }

    return inner_count;
}

const Coord = struct {
    x: usize,
    y: usize,
};

const SideInfo = struct {
    up_is_inner: ?bool = null,
    down_is_inner: ?bool = null,
    left_is_inner: ?bool = null,
    right_is_inner: ?bool = null,
};

const Map = struct {
    string: []u8,
    width: usize,
    height: usize,

    fn at(self: Map, coord: Coord) u8 {
        return self.string[coord.y * self.width + coord.x];
    }

    fn findConnections(self: Map, coord: Coord) [2]Coord {
        return switch (self.at(coord)) {
            '|' => .{ .{ .x = coord.x, .y = coord.y - 1 }, .{ .x = coord.x, .y = coord.y + 1 } },
            '-' => .{ .{ .x = coord.x - 1, .y = coord.y }, .{ .x = coord.x + 1, .y = coord.y } },
            'F' => .{ .{ .x = coord.x, .y = coord.y + 1 }, .{ .x = coord.x + 1, .y = coord.y } },
            'J' => .{ .{ .x = coord.x - 1, .y = coord.y }, .{ .x = coord.x, .y = coord.y - 1 } },
            '7' => .{ .{ .x = coord.x - 1, .y = coord.y }, .{ .x = coord.x, .y = coord.y + 1 } },
            'L' => .{ .{ .x = coord.x, .y = coord.y - 1 }, .{ .x = coord.x + 1, .y = coord.y } },
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
    const expected: i32 = 4;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}

test "example03" {
    const text = @embedFile("example03.txt");
    const expected: i32 = 8;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}

test "example04" {
    const text = @embedFile("example04.txt");
    const expected: i32 = 10;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
