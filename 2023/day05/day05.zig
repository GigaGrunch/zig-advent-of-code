const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var maps = std.ArrayList(Map).init(allocator);
    defer maps.deinit();

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        if (utils.contains(line, ':')) {
            var parts_it = utils.tokenize(line, ":");
            const prefix = parts_it.next().?;

            if (utils.endsWith(prefix, "map")) {
                var prefix_it = utils.tokenize(prefix, " ");
                const map_name = prefix_it.next().?;

                var name_it = utils.tokenize(map_name, "-");
                const from = name_it.next().?;
                std.debug.assert(utils.streql(name_it.next().?, "to"));
                const to = name_it.next().?;

                try maps.append(.{
                    .from = from,
                    .to = to,
                });
            } else if (utils.streql(prefix, "seeds")) {
                // seeds
            } else {
                unreachable;
            }
        } else {
            // values
        }
    }

    for (maps.items) |map| {
        std.debug.print("{s} -> {s}\n", .{ map.from, map.to });
    }

    return 0;
}

const Map = struct {
    from: []const u8,
    to: []const u8,
};

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 35;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
