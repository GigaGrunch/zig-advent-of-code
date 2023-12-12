const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        var line_it = utils.tokenize(line, " ");
        const spring_list = line_it.next().?;

        var groups_list = std.ArrayList(i32).init(allocator);
        defer groups_list.deinit();

        var groups_it = utils.tokenize(line_it.next().?, ",");
        while (groups_it.next()) |group_string| {
            const group = try utils.parseInt(i32, group_string);
            try groups_list.append(group);
        }

        const groups = groups_list.items;

        std.debug.print("{s} {any}\n", .{ spring_list, groups });
    }

    return 0;
}

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 21;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
