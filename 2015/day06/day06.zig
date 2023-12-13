const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = allocator;

    var lights = [_]bool{false} ** 1_000_000;

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        var parts_it = utils.tokenize(line, " ");
        const command = parseCommand(&parts_it);
        const start_coords = try parseCoords(parts_it.next().?);
        std.debug.assert(utils.streql(parts_it.next().?, "through"));
        const end_coords = try parseCoords(parts_it.next().?);

        for (start_coords.y..end_coords.y + 1) |y| {
            for (start_coords.x..end_coords.x + 1) |x| {
                const index = y * 1000 + x;
                lights[index] = switch (command) {
                    .TurnOn => true,
                    .TurnOff => false,
                    .Toggle => !lights[index],
                };
            }
        }
    }

    var sum: i32 = 0;

    for (lights) |light| {
        if (light == true) sum += 1;
    }

    return sum;
}

fn parseCommand(it: anytype) enum { TurnOn, TurnOff, Toggle } {
    const first_word = it.next().?;

    if (utils.streql(first_word, "toggle")) return .Toggle;
    if (utils.streql(first_word, "turn")) {
        const second_word = it.next().?;
        if (utils.streql(second_word, "on")) return .TurnOn;
        if (utils.streql(second_word, "off")) return .TurnOff;
    }

    unreachable;
}

fn parseCoords(string: []const u8) !struct { x: usize, y: usize } {
    var it = utils.tokenize(string, ",");
    return .{
        .x = try utils.parseInt(usize, it.next().?),
        .y = try utils.parseInt(usize, it.next().?),
    };
}

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 1_000_000 - 1000 - 4;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
