const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = allocator;

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        std.debug.print("line: {s}\n", .{line});

        if (utils.contains(line, ':')) {
            var parts_it = utils.tokenize(line, ":");
            const prefix = parts_it.next().?;
            std.debug.print("  prefix: {s}\n", .{prefix});

            if (utils.endsWith(prefix, "map")) {
                var prefix_it = utils.tokenize(prefix, " ");
                const map_name = prefix_it.next().?;
                std.debug.print("    map: {s}\n", .{map_name});

                var name_it = utils.tokenize(map_name, "-");
                const from = name_it.next().?;
                std.debug.print("      from: {s}\n", .{from});
                std.debug.assert(utils.streql(name_it.next().?, "to"));
                const to = name_it.next().?;
                std.debug.print("      to: {s}\n", .{to});
            } else if (utils.streql(prefix, "seeds")) {
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
