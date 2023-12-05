const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var current_values = std.ArrayList(Value).init(allocator);
    defer current_values.deinit();

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        if (utils.contains(line, ':')) {
            var parts_it = utils.tokenize(line, ":");
            const prefix = parts_it.next().?;

            if (utils.streql(prefix, "seeds")) {
                std.debug.assert(current_values.items.len == 0);

                const values = parts_it.next().?;
                var values_it = utils.tokenize(values, " ");
                while (values_it.next()) |value| {
                    try current_values.append(.{
                        .number = try parseInt(value),
                        .converted = false,
                    });
                }
            } else if (utils.endsWith(prefix, "map")) {
                for (current_values.items) |*value| {
                    value.converted = false;
                }
            } else {
                unreachable;
            }
        } else {
            std.debug.assert(current_values.items.len > 0);
            var values_it = utils.tokenize(line, " ");
            const dest_start = try parseInt(values_it.next().?);
            const source_start = try parseInt(values_it.next().?);
            const length = try parseInt(values_it.next().?);

            for (current_values.items) |*value| {
                if (value.converted) continue;
                if (value.number >= source_start and value.number < source_start + length) {
                    const offset = value.number - source_start;
                    const old_number = value.number;
                    _ = old_number;
                    value.number = dest_start + offset;
                    value.converted = true;
                }
            }
        }
    }

    var min: i64 = std.math.maxInt(i64);
    for (current_values.items) |value| {
        min = @min(min, value.number);
    }

    return @as(i32, @intCast(min));
}

pub fn parseInt(text: []const u8) !i64 {
    return try std.fmt.parseInt(i64, text, 10);
}

const Value = struct {
    number: i64,
    converted: bool,
};

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 35;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
