const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = allocator;

    var lines_it = utils.tokenize(text, "/r/n");
    while (lines_it.next()) |line| {
        if (utils.contains(line, ':')) {
            var parts_it = utils.tokenize(line, ":");
            const prefix = parts_it.next().?;

            if (utils.endsWith(prefix, "map")) {
                // map
            } else if (utils.endsWith(prefix, "seeds")) {
                // seeds
            } else {
                unreachable;
            }
        } else {
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
