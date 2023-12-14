const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var width: usize = 0;
    var height: usize = 0;
    var map_string = std.ArrayList(u8).init(allocator);
    defer map_string.deinit();

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        try map_string.appendSlice(line);
        height += 1;
        width = line.len;
    }

    var map = Map{
        .string = map_string.items,
        .width = width,
        .height = height,
    };

    std.debug.print("\ninitial:\n\n", .{});
    map.print();

    // north
    for (0..map.height) |y| {
        for (0..map.width) |x| {
            if (map.get(x, y) == 'O') {
                var other_y = y;
                while (other_y > 0) : (other_y -= 1) {
                    if (map.get(x, other_y - 1) != '.') break;
                    map.set(x, other_y, '.');
                    map.set(x, other_y - 1, 'O');
                }
            }
        }
    }

    std.debug.print("\nnorth:\n\n", .{});
    map.print();

    // east
    for (0..map.width) |x| {
        for (0..map.height) |y| {
            if (map.get(x, y) == 'O') {
                var other_x = x;
                while (other_x > 0) : (other_x -= 1) {
                    if (map.get(other_x - 1, y) != '.') break;
                    map.set(other_x, y, '.');
                    map.set(other_x - 1, y, 'O');
                }
            }
        }
    }

    std.debug.print("\neast:\n\n", .{});
    map.print();

    // south
    for (0..map.height) |inv_y| {
        const y = map.height - 1 - inv_y;
        for (0..map.width) |x| {
            if (map.get(x, y) == 'O') {
                var other_y = y;
                while (other_y < map.height - 1) : (other_y += 1) {
                    if (map.get(x, other_y + 1) != '.') break;
                    map.set(x, other_y, '.');
                    map.set(x, other_y + 1, 'O');
                }
            }
        }
    }

    std.debug.print("\nsouth:\n\n", .{});
    map.print();

    // west
    for (0..map.width) |inv_x| {
        const x = map.width - 1 - inv_x;
        for (0..map.height) |y| {
            if (map.get(x, y) == 'O') {
                var other_x = x;
                while (other_x < map.width - 1) : (other_x += 1) {
                    if (map.get(other_x + 1, y) != '.') break;
                    map.set(other_x, y, '.');
                    map.set(other_x + 1, y, 'O');
                }
            }
        }
    }

    std.debug.print("\nwest:\n\n", .{});
    map.print();

    var load: i32 = 0;

    for (0..map.height) |y| {
        const row = map.row(y);
        for (row) |char| {
            if (char == 'O') {
                load += @intCast(map.height - y);
            }
        }
    }

    return load;
}

const Map = struct {
    string: []u8,
    width: usize,
    height: usize,

    fn set(map: Map, x: usize, y: usize, char: u8) void {
        map.string[y * map.width + x] = char;
    }

    fn get(map: Map, x: usize, y: usize) u8 {
        return map.string[y * map.width + x];
    }

    fn row(map: Map, y: usize) []u8 {
        const start = y * map.width;
        const end = start + map.width;
        return map.string[start..end];
    }

    fn print(map: Map) void {
        for (0..map.height) |y| {
            std.debug.print("{s}\n", .{map.row(y)});
        }
    }
};

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 64;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
