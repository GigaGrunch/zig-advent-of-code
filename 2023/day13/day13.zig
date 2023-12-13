const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = allocator;

    const empty_line = if (utils.containsString(text, "\r\n")) "\r\n\r\n" else "\n\n";

    var patterns_it = std.mem.split(u8, text, empty_line);
    while (patterns_it.next()) |pattern| {
        var lines_it = utils.tokenize(pattern, "\r\n");
        while (lines_it.next()) |line| {
            std.debug.print("{s}\n", .{line});
        }

        std.debug.print("\n", .{});
    }

    return 0;
}

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 405;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
