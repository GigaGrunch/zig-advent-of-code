const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !u64 {
    var visited_positions = std.ArrayList(Pos).init(allocator);
    defer visited_positions.deinit();

    var current_pos = Pos{ .x = 0, .y = 0 };
    try visited_positions.append(current_pos);

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        var line_it = utils.tokenize(line, " ()#");
        _ = line_it.next().?;
        _ = line_it.next().?;

        const hex = line_it.next().?;
        const count = try std.fmt.parseInt(u64, hex[0..5], 16);
        const dir: u8 = switch (hex[5]) {
            '0' => 'R',
            '1' => 'D',
            '2' => 'L',
            '3' => 'U',
            else => unreachable,
        };

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
        .x = std.math.maxInt(i32),
        .y = std.math.maxInt(i32),
    };
    var bottom_right = Pos{
        .x = std.math.minInt(i32),
        .y = std.math.minInt(i32),
    };

    for (visited_positions.items) |pos| {
        top_left.x = @min(top_left.x, pos.x);
        top_left.y = @min(top_left.y, pos.y);
        bottom_right.x = @max(bottom_right.x, pos.x);
        bottom_right.y = @max(bottom_right.y, pos.y);
    }

    const width: usize = @intCast(1 + bottom_right.x - top_left.x);
    const height: usize = @intCast(1 + bottom_right.y - top_left.y);

    var map = std.ArrayList(Tile).init(allocator);
    defer map.deinit();

    for (0..height) |y| {
        for (0..width) |x| {
            const x_pos = @as(i32, @intCast(x)) + top_left.x;
            const y_pos = @as(i32, @intCast(y)) + top_left.y;
            if (utils.containsItem(visited_positions.items, Pos{ .x = x_pos, .y = y_pos })) {
                try map.append(.Edge);
            } else {
                try map.append(.Unknown);
            }
        }
    }

    // std.debug.print("outline:\n", .{});
    // for (0..height) |y| {
    //     for (0..width) |x| {
    //         const index = y * width + x;
    //         switch (map.items[index]) {
    //             .Edge, .Inner => std.debug.print("#", .{}),
    //             .Unknown, .Outer => std.debug.print(".", .{}),
    //         }
    //     }
    //     std.debug.print("\n", .{});
    // }

    while (true) {
        for (0..height) |y| {
            for (0..width) |x| {
                const index = y * width + x;

                if (map.items[index] != .Unknown) continue;

                if (x == 0 or y == 0) {
                    map.items[index] = .Outer;
                    continue;
                }
                if (x > 0) {
                    const prev = map.items[index - 1];
                    if (prev != .Unknown and prev != .Edge) {
                        map.items[index] = prev;
                        continue;
                    }
                }
                if (x == 1) {
                    const prev = map.items[index - 1];
                    if (prev == .Edge) {
                        map.items[index] = .Inner;
                        continue;
                    }
                }
                if (y > 0) {
                    const prev = map.items[index - width];
                    if (prev != .Unknown and prev != .Edge) {
                        map.items[index] = prev;
                        continue;
                    }
                }
                if (y == 1) {
                    const prev = map.items[index - width];
                    if (prev == .Edge) {
                        map.items[index] = .Inner;
                        continue;
                    }
                }
            }
        }

        for (0..height) |inv_y| {
            for (0..width) |inv_x| {
                const x = width - 1 - inv_x;
                const y = height - 1 - inv_y;

                const index = y * width + x;

                if (map.items[index] != .Unknown) continue;

                if (x == width - 1 or y == height - 1) {
                    map.items[index] = .Outer;
                    continue;
                }
                if (x < width - 1) {
                    const next = map.items[index + 1];
                    if (next != .Unknown and next != .Edge) {
                        map.items[index] = next;
                        continue;
                    }
                }
                if (x == width - 2) {
                    const next = map.items[index + 1];
                    if (next == .Edge) {
                        map.items[index] = .Inner;
                        continue;
                    }
                }
                if (y < height - 1) {
                    const next = map.items[index + width];
                    if (next != .Unknown and next != .Edge) {
                        map.items[index] = next;
                        continue;
                    }
                }
                if (y == height - 2) {
                    const next = map.items[index + width];
                    if (next == .Edge) {
                        map.items[index] = .Inner;
                        continue;
                    }
                }
            }
        }

        var unknown_count: u64 = 0;
        for (0..height) |y| {
            for (0..width) |x| {
                const index = y * width + x;
                if (map.items[index] == .Unknown) {
                    unknown_count += 1;
                }
            }
        }

        if (unknown_count == 0) break;
    }

    var count: u64 = 0;

    for (0..height) |y| {
        for (0..width) |x| {
            const index = y * width + x;
            switch (map.items[index]) {
                .Edge, .Inner => {
                    count += 1;
                },
                .Unknown, .Outer => {},
            }
        }
    }

    return count;
}

const Pos = struct {
    x: i32,
    y: i32,
};

const Tile = enum {
    Edge,
    Unknown,
    Outer,
    Inner,
};

test {
    const text = @embedFile("example.txt");
    const expected: u64 = 952408144115;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
