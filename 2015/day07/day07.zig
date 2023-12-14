const std = @import("std");
const utils = @import("utils");

var wire_names: std.ArrayList([]const u8) = undefined;
var wire_values: std.ArrayList(u16) = undefined;

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    wire_names = std.ArrayList([]const u8).init(allocator);
    wire_values = std.ArrayList(u16).init(allocator);
    defer {
        wire_names.deinit();
        wire_values.deinit();
    }

    while (true) {
        var unknown_values: i32 = 0;

        var lines_it = utils.tokenize(text, "\r\n");
        while (lines_it.next()) |line| {
            var line_it = std.mem.split(u8, line, " -> ");
            const from = line_it.next().?;
            const to = line_it.next().?;
            if (try getFromValue(from)) |value| {
                var wire_index: usize = 0;
                while (wire_index < wire_names.items.len) : (wire_index += 1) {
                    if (utils.streql(wire_names.items[wire_index], to)) {
                        break;
                    }
                }

                if (wire_index == wire_names.items.len) {
                    try wire_names.append(to);
                    try wire_values.append(value);
                } else {
                    wire_values.items[wire_index] = value;
                }
            } else {
                unknown_values += 1;
            }
        }

        if (unknown_values == 0) {
            break;
        }
    }

    const a_value = for (wire_names.items, 0..) |wire_name, i| {
        if (utils.streql(wire_name, "a")) {
            break wire_values.items[i];
        }
    } else unreachable;

    wire_names.clearRetainingCapacity();
    wire_values.clearRetainingCapacity();
    try wire_names.append("b");
    try wire_values.append(a_value);

    while (true) {
        var unknown_values: i32 = 0;

        var lines_it = utils.tokenize(text, "\r\n");
        while (lines_it.next()) |line| {
            var line_it = std.mem.split(u8, line, " -> ");
            const from = line_it.next().?;
            const to = line_it.next().?;

            if (utils.streql(to, "b")) {
                continue;
            }

            if (try getFromValue(from)) |value| {
                var wire_index: usize = 0;
                while (wire_index < wire_names.items.len) : (wire_index += 1) {
                    if (utils.streql(wire_names.items[wire_index], to)) {
                        break;
                    }
                }

                if (wire_index == wire_names.items.len) {
                    try wire_names.append(to);
                    try wire_values.append(value);
                } else {
                    wire_values.items[wire_index] = value;
                }
            } else {
                unknown_values += 1;
            }
        }

        if (unknown_values == 0) {
            break;
        }
    }

    for (wire_names.items, 0..) |wire_name, i| {
        if (utils.streql(wire_name, "a")) {
            return wire_values.items[i];
        }
    }

    unreachable;
}

fn getFromValue(string: []const u8) !?u16 {
    var string_it = utils.tokenize(string, " ");

    if (string_it.next()) |string_1| {
        if (string_it.next()) |string_2| {
            if (string_it.next()) |string_3| {
                const a = try getValue(string_1);
                if (a == null) return null;
                const b = try getValue(string_3);
                if (b == null) return null;

                if (utils.streql(string_2, "AND")) return a.? & b.?;
                if (utils.streql(string_2, "OR")) return a.? | b.?;
                if (utils.streql(string_2, "LSHIFT")) return a.? << @intCast(b.?);
                if (utils.streql(string_2, "RSHIFT")) return a.? >> @intCast(b.?);

                unreachable;
            }

            const a = try getValue(string_2);
            if (a == null) return null;

            if (utils.streql(string_1, "NOT")) return ~a.?;

            unreachable;
        }

        return try getValue(string_1);
    }

    unreachable;
}

fn getValue(string: []const u8) !?u16 {
    const is_number = switch (string[0]) {
        '0'...'9' => true,
        else => false,
    };

    if (is_number) return try utils.parseInt(u16, string);

    for (wire_names.items, 0..) |wire_name, i| {
        if (utils.streql(wire_name, string)) {
            return wire_values.items[i];
        }
    }

    return null;
}
