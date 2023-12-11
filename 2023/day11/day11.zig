const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var width: i32 = 0;
    var height: i32 = 0;

    var galaxies = std.ArrayList(Pos).init(allocator);
    defer galaxies.deinit();

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        width = @intCast(line.len);
        height += 1;

        for (line, 0..) |char, x| {
            if (char == '#') try galaxies.append(.{ .x = @intCast(x), .y = height });
        }
    }

    std.debug.print("width: {d}, height: {d}\n", .{ width, height });
    std.debug.print("galaxies: ", .{});
    for (galaxies.items) |pos| std.debug.print("({d},{d}) ", .{ pos.x, pos.y });
    std.debug.print("\n", .{});

    return 0;
}

const Pos = struct {
    x: i32,
    y: i32,
};

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 374;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
