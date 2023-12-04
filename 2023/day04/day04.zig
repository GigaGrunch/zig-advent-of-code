const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var card_copies = std.AutoHashMap(i32, i32).init(allocator);
    defer card_copies.deinit();

    var card_count: i32 = 0;

    var card_index: i32 = 0;
    var lines_it = std.mem.tokenizeAny(u8, text, "\r\n");
    while (lines_it.next()) |line| {
        var card_score: i32 = 0;

        var winning_numbers = std.ArrayList(i32).init(allocator);
        defer winning_numbers.deinit();

        var parts_it = std.mem.tokenizeAny(u8, line, ":|");
        const card_name = parts_it.next().?;
        _ = card_name;

        var winning_numbers_it = std.mem.tokenizeAny(u8, parts_it.next().?, " ");
        while (winning_numbers_it.next()) |number_string| {
            const number = try std.fmt.parseInt(i32, number_string, 10);
            try winning_numbers.append(number);
        }

        const self_copies = card_copies.get(card_index) orelse 0;
        card_count += 1 + self_copies;

        var owned_numbers_it = std.mem.tokenizeAny(u8, parts_it.next().?, " ");
        while (owned_numbers_it.next()) |number_string| {
            const owned_number = try std.fmt.parseInt(i32, number_string, 10);
            for (winning_numbers.items) |winning_number| {
                if (winning_number == owned_number) {
                    card_score += 1;

                    var copy_entry = try card_copies.getOrPut(card_index + card_score);
                    if (copy_entry.found_existing) {
                        copy_entry.value_ptr.* += 1 + self_copies;
                    } else {
                        copy_entry.value_ptr.* = 1 + self_copies;
                    }
                }
            }
        }

        card_index += 1;
    }

    return card_count;
}

test {
    const text = @embedFile("example.txt");
    const expected_result: i32 = 30;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected_result, result);
}
