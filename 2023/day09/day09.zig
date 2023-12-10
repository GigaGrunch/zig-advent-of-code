const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        var sequence_stack = std.ArrayList(std.ArrayList(i32)).init(allocator);
        defer {
            for (sequence_stack.items) |sequence| sequence.deinit();
            sequence_stack.deinit();
        }

        var original_sequence = try appendGet(std.ArrayList(i32), &sequence_stack);
        original_sequence.* = std.ArrayList(i32).init(allocator);

        var line_it = utils.tokenize(line, " ");
        while (line_it.next()) |number_string| {
            try original_sequence.append(try utils.parseInt(i32, number_string));
        }

        while (true) {
            var current = sequence_stack.items[sequence_stack.items.len - 1];

            var inner = try appendGet(std.ArrayList(i32), &sequence_stack);
            inner.* = std.ArrayList(i32).init(allocator);

            for (current.items[0..current.items.len - 1], current.items[1..]) |a, b| {
                try inner.append(b - a);
            }

            var all_equal = true;
            for (inner.items) |number| {
                if (number != inner.items[0]) {
                    all_equal = false;
                    break;
                }
            }
            if (all_equal) break;
        }

        for (sequence_stack.items) |sequence| {
            for (sequence.items) |number| {
                std.debug.print("{d} ", .{number});
            }
            std.debug.print("\n", .{});
        }
    }

    return 0;
}

fn appendGet(comptime T: type, list: *std.ArrayList(T)) !*T {
    const index = list.items.len;
    try list.append(undefined);
    return &list.items[index];
}

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 114;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
