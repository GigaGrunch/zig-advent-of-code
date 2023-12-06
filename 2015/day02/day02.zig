const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = allocator;

    var result: i32 = 0;

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        var edges_it = utils.tokenize(line, "x");
        const length = try utils.parseInt(i32, edges_it.next().?);
        const width = try utils.parseInt(i32, edges_it.next().?);
        const height = try utils.parseInt(i32, edges_it.next().?);

        var ribbons: [3]i32 = .{
            2 * length + 2 * width,
            2 * length + 2 * height,
            2 * width + 2 * height,
        };
        result += std.mem.min(i32, &ribbons);
        result += length * width * height;
    }

    return result;
}

test "2x3x4" {
    const expected: i32 = 34;
    const result = try execute("2x3x4", std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}

test "1x1x10" {
    const expected: i32 = 14;
    const result = try execute("1x1x10", std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
