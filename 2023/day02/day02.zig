const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = allocator;
    var power_sum: i32 = 0;

    var lines = std.mem.tokenizeAny(u8, text, "\r\n");
    while (lines.next()) |line| {
        var outer = std.mem.tokenizeAny(u8, line, ":");
        const prefix = outer.next().?;
        const content = outer.next().?;
        std.debug.assert(outer.next() == null);

        std.debug.assert(std.mem.startsWith(u8, prefix, "Game "));
        const game_number = try std.fmt.parseInt(i32, prefix[5..], 10);
        _ = game_number;

        var min_red: i32 = 0;
        var min_green: i32 = 0;
        var min_blue: i32 = 0;

        var sets = std.mem.tokenizeAny(u8, content, ";");
        while (sets.next()) |set| {
            var cubes = std.mem.tokenizeAny(u8, set, ",");
            while (cubes.next()) |cube| {
                var cube_parts = std.mem.tokenizeAny(u8, cube, " ");
                const count_string = cube_parts.next().?;
                const color = cube_parts.next().?;
                const count = try std.fmt.parseInt(i32, count_string, 10);

                if (streql(color, "red")) min_red = @max(min_red, count);
                if (streql(color, "green")) min_green = @max(min_green, count);
                if (streql(color, "blue")) min_blue = @max(min_blue, count);
            }
        }

        const power = min_red * min_green * min_blue;
        power_sum += power;
    }

    return power_sum;
}

fn streql(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 2286;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
