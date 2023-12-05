const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var current_values = std.ArrayList(i64).init(allocator);
    defer current_values.deinit();

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        if (utils.contains(line, ':')) {
            var parts_it = utils.tokenize(line, ":");
            const prefix = parts_it.next().?;

            if (utils.streql(prefix, "seeds")) {
                const values = parts_it.next().?;
                var values_it = utils.tokenize(values, " ");
                while (values_it.next()) |value| {
                    const number = try std.fmt.parseInt(i64, value, 10);
                    try current_values.append(number);
                }
            } else if (utils.endsWith(prefix, "map")) {
                std.debug.assert(current_values.items.len > 0);
                // new map
            } else {
                unreachable;
            }
        } else {
            std.debug.assert(current_values.items.len > 0);
            // values
        }
    }

    return 0;
}

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 35;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
