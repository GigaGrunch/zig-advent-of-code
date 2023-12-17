const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var map_list = std.ArrayList(i32).init(allocator);
    defer map_list.deinit();
    height = 0;

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        height += 1;

        for (line) |char| {
            try map_list.append(char - '0');
        }
    }

    map = map_list.items;
    width = map.len / height;

    for (0..height) |y| {
        const start = y * width;
        const end = start + width;
        std.debug.print("{any}\n", .{map[start..end]});
    }

    return 0;
}

var map: []const i32 = undefined;
var width: usize = undefined;
var height: usize = undefined;

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 102;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
