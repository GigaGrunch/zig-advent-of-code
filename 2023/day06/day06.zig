const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var times = std.ArrayList(i32).init(allocator);
    defer times.deinit();
    var records = std.ArrayList(i32).init(allocator);
    defer records.deinit();

    var lines_it = utils.tokenize(text, "\r\n");

    const times_line = lines_it.next().?;
    var times_it = utils.tokenize(times_line, " ");
    std.debug.assert(utils.streql(times_it.next().?, "Time:"));
    while (times_it.next()) |time| try times.append(try utils.parseInt(time));

    const records_line = lines_it.next().?;
    var records_it = utils.tokenize(records_line, " ");
    std.debug.assert(utils.streql(records_it.next().?, "Distance:"));
    while (records_it.next()) |record| try records.append(try utils.parseInt(record));

    return 0;
}

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 288;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
