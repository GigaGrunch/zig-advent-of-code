const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var time_string = std.ArrayList(u8).init(allocator);
    defer time_string.deinit();
    var record_string = std.ArrayList(u8).init(allocator);
    defer record_string.deinit();

    var lines_it = utils.tokenize(text, "\r\n");

    const time_line = lines_it.next().?;
    var time_it = utils.tokenize(time_line, " ");
    std.debug.assert(utils.streql(time_it.next().?, "Time:"));
    while (time_it.next()) |part| try time_string.appendSlice(part);
    const time = try utils.parseInt(usize, time_string.items);

    const record_line = lines_it.next().?;
    var record_it = utils.tokenize(record_line, " ");
    std.debug.assert(utils.streql(record_it.next().?, "Distance:"));
    while (record_it.next()) |part| try record_string.appendSlice(part);
    const record = try utils.parseInt(usize, record_string.items);

    var num_winning_games: usize = 0;
    for (1..time) |hold_time| {
        const travel_time = time - hold_time;
        const velocity = hold_time;
        const distance = velocity * travel_time;
        if (distance > record) num_winning_games += 1;
    }

    return @intCast(num_winning_games);
}

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 71503;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
