const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var hands = std.ArrayList([]const u8).init(allocator);
    defer hands.deinit();
    var bids = std.ArrayList(i32).init(allocator);
    defer bids.deinit();

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        var parts_it = utils.tokenize(line, " ");
        try hands.append(parts_it.next().?);
        try bids.append(try utils.parseInt(i32, parts_it.next().?));
    }

    for (hands.items, bids.items) |hand, bid| {
        std.debug.print("{s} {d}\n", .{ hand, bid });
    }

    return 0;
}

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 6440;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
