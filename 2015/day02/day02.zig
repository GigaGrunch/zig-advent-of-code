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
        const length = try utils.parseInt(edges_it.next().?);
        const width = try utils.parseInt(edges_it.next().?);
        const height = try utils.parseInt(edges_it.next().?);

        var faces: [3]i32 = undefined;
        faces[0] = length * width;
        faces[1] = length * height;
        faces[2] = width * height;

        for (faces) |face| result += 2 * face;
        result += std.mem.min(i32, &faces);
    }

    return result;
}

test "2x3x4" {
    const expected: i32 = 58;
    const result = try execute("2x3x4", std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}

test "1x1x10" {
    const expected: i32 = 43;
    const result = try execute("1x1x10", std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
