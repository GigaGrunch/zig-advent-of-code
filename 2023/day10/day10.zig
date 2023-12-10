const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var string = std.ArrayList(u8).init(allocator);
    defer string.deinit();

    var width: usize = undefined;
    var height: usize = 0;
    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        width = line.len;
        height += 1;
        try string.appendSlice(line);
    }

    const map = Map {
        .string = string.items,
        .width = width,
        .height = height,
    };

    for (0..height) |y| {
        const start = y * width;
        const end = start + width;
        std.debug.print("{s}\n", .{map.string[start..end]});
    }

    return 0;
}

const Map = struct {
    string: []const u8,
    width: usize,
    height: usize,  
};

test "example01" {
    const text = @embedFile("example01.txt");
    const expected: i32 = 4;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}

test "example02" {
    const text = @embedFile("example02.txt");
    const expected: i32 = 8;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
