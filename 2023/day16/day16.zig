const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !usize {   
    var starting_configs = std.ArrayList(Beam).init(allocator);
    var string = std.ArrayList(u8).init(allocator);
    defer {
        starting_configs.deinit();
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

    for (0..map.width) |x| {
        try starting_configs.append(.{ .x = x, .y = 0, .direction = .Down });
        try starting_configs.append(.{ .x = x, .y = map.height - 1, .direction = .Up });
    }

    for (0..map.height) |y| {
        try starting_configs.append(.{ .x = 0, .y = y, .direction = .Right });
        try starting_configs.append(.{ .x = map.width - 1, .y = y, .direction = .Left });
    }

    var highest_result: usize = 0;

    for (starting_configs.items) |starting_config| {
        var energized = std.ArrayList(Tile).init(allocator);
        var frontier = std.ArrayList(Beam).init(allocator);
        defer {
            energized.deinit();
            frontier.deinit();
        }

        try frontier.append(starting_config);

        while (frontier.items.len > 0) {
            var beam = frontier.pop();
            while (true) {
                const index = beam.y * map.width + beam.x;

                var tile: *Tile = undefined;

                if (!for (energized.items) |*t| {
                    if (t.index == index) {
                        tile = t;
                        break true;
                    }
                } else false) {
                    try energized.append(.{ .index = index });
                    tile = &energized.items[energized.items.len - 1];
                }

                if (tile.isEnergized(beam.direction)) break;
                tile.setEnergized(beam.direction);

                switch (map.string[index]) {
                    '.' => if (!beam.step(map)) break,
                    '/', '\\' => {
                        beam.changeDirection(map.string[index]);
                        if (!beam.step(map)) break;
                    },
                    '-' => switch (beam.direction) {
                        .Right, .Left => if (!beam.step(map)) break,
                        .Up, .Down => {
                            beam.direction = .Left;
                            try frontier.append(beam);
                            beam.direction = .Right;
                        },
                    },
                    '|' => switch (beam.direction) {
                        .Up, .Down => if (!beam.step(map)) break,
                        .Right, .Left => {
                            beam.direction = .Up;
                            try frontier.append(beam);
                            beam.direction = .Down;
                        },
                    },
                    else => unreachable,
                }
            }
        }

        highest_result = @max(highest_result, energized.items.len);
    }

    return highest_result;
}

const Tile = struct {
    index: usize,
    energized: [4]bool = [_]bool {false} ** 4,

    fn isEnergized(tile: Tile, direction: Direction) bool {
        return tile.energized[energizedIndex(direction)];
    }

    fn setEnergized(tile: *Tile, direction: Direction) void {
        tile.energized[energizedIndex(direction)] = true;
    }

    fn energizedIndex(direction: Direction) usize {
        return switch (direction) {
            .Right => 0,
            .Left => 1,
            .Up => 2,
            .Down => 3,
        };
    }
};

const Direction = enum { Right, Left, Up, Down };

const Beam = struct {
    x: usize,
    y: usize,
    direction: Direction,

    fn changeDirection(beam: *Beam, char: u8) void {
        beam.direction = switch (beam.direction) {
            .Right => switch (char) {
                '/' => .Up,
                '\\' => .Down,
                else => unreachable,
            },
            .Left => switch (char) {
                '/' => .Down,
                '\\' => .Up,
                else => unreachable,
            },
            .Up => switch (char) {
                '/' => .Right,
                '\\' => .Left,
                else => unreachable,
            },
            .Down => switch (char) {
                '/' => .Left,
                '\\' => .Right,
                else => unreachable,
            },
        };
    }

    fn step(beam: *Beam, map: Map) bool {
        switch (beam.direction) {
            .Right => {
                if (beam.x < map.width - 1) {
                    beam.x += 1;
                    return true;
                }
            },
            .Left => {
                if (beam.x > 0) {
                    beam.x -= 1;
                    return true;
                }
            },
            .Up => {
                if (beam.y > 0) {
                    beam.y -= 1;
                    return true;
                }
            },
            .Down => {
                if (beam.y < map.height - 1) {
                    beam.y += 1;
                    return true;
                }
            },
        }

        return false;
    }
};

const Map = struct {
    string: []const u8,
    width: usize,
    height: usize,

    fn char(map: Map, x: usize, y: usize) u8 {
        return map.string[y * map.width + x];
    }

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
    const expected: usize = 51;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
