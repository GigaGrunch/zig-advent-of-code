const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var visited_positions = std.ArrayList(Pos).init(allocator);
    defer visited_positions.deinit();

    var current_pos = Pos{ .x = 0, .y = 0 };
    try visited_positions.append(current_pos);

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        var line_it = utils.tokenize(line, " ");
        const dir = line_it.next().?[0];
        const count = try utils.parseInt(usize, line_it.next().?);

        for (0..count) |_| {
            switch (dir) {
                'U' => current_pos.y -= 1,
                'D' => current_pos.y += 1,
                'L' => current_pos.x -= 1,
                'R' => current_pos.x += 1,
                else => unreachable,
            }

            try visited_positions.append(current_pos);
        }
    }

    var top_left = Pos{
        .x = std.math.maxInt(usize),
        .y = std.math.maxInt(usize),
    };
    var bottom_right = Pos{
        .x = std.math.minInt(usize),
        .y = std.math.minInt(usize),
    };

    for (visited_positions.items) |pos| {
        top_left.x = @min(top_left.x, pos.x);
        top_left.y = @min(top_left.y, pos.y);
        bottom_right.x = @max(bottom_right.x, pos.x);
        bottom_right.y = @max(bottom_right.y, pos.y);
    }

    const width = 1 + bottom_right.x - top_left.x;
    const height = 1 + bottom_right.y - top_left.y;

    var map = std.ArrayList(Tile).init(allocator);
    defer map.deinit();

    for (top_left.y..bottom_right.y + 1) |y| {
        for (top_left.x..bottom_right.x + 1) |x| {
            if (utils.containsItem(visited_positions.items, Pos{ .x = x, .y = y })) {
                try map.append(.Edge);
            } else {
                try map.append(.Outer);
            }
        }
    }

    std.debug.print("outline:\n", .{});
    for (0..height) |y| {
        for (0..width) |x| {
            const index = y * width + x;
            switch (map.items[index]) {
                .Edge, .Inner => std.debug.print("#", .{}),
                .Outer => std.debug.print(".", .{}),
            }
        }
        std.debug.print("\n", .{});
    }

    for (0..height) |y| {
        var is_outside = true;

        for (0..width) |x| {
            const index = y * width + x;
            switch (map.items[index]) {
                .Edge => {
                    if (x < width - 1) {
                        const next = map.items[index + 1];
                        if (next != .Edge) is_outside = !is_outside;
                    }
                },
                .Outer, .Inner => map.items[index] = if (is_outside) .Outer else .Inner,
            }
        }
    }

    std.debug.print("lagoon:\n", .{});
    for (0..height) |y| {
        for (0..width) |x| {
            const index = y * width + x;
            switch (map.items[index]) {
                .Edge, .Inner => std.debug.print("#", .{}),
                .Outer => std.debug.print(".", .{}),
            }
        }
        std.debug.print("\n", .{});
    }

    return 0;
}

const Pos = struct {
    x: usize,
    y: usize,
};

const Tile = enum {
    Edge,
    Outer,
    Inner,
};

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 62;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
