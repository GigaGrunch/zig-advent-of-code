const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var hands = std.ArrayList(Hand).init(allocator);
    defer hands.deinit();
    var bids = std.ArrayList(i32).init(allocator);
    defer bids.deinit();

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        var parts_it = utils.tokenize(line, " ");
        const cards = parts_it.next().?;
        try hands.append(.{
            .cards = cards,
            .type = getType(cards),
        });
        try bids.append(try utils.parseInt(i32, parts_it.next().?));
    }

    for (hands.items, bids.items) |hand, bid| {
        std.debug.print("{} {s} {d}\n", .{ hand.type, hand.cards, bid });
    }

    return 0;
}

fn getType(hand: []const u8) HandType {
    var counts = [_]i32{0} ** card_types.len;
    for (hand) |card| {
        const index = std.mem.indexOfScalar(u8, card_types, card).?;
        counts[index] += 1;
    }

    std.mem.sort(i32, &counts, {}, greaterThan);

    return switch (counts[0]) {
        5 => .FiveOfAKind,
        4 => .FourOfAKind,
        3 => switch (counts[1]) {
            2 => .FullHouse,
            1 => .ThreeOfAKind,
            else => unreachable,
        },
        2 => switch (counts[1]) {
            2 => .TwoPair,
            1 => .OnePair,
            else => unreachable,
        },
        1 => .HighCard,
        else => unreachable,
    };
}

fn greaterThan(context: void, a: i32, b: i32) bool {
    _ = context;
    return a > b;
}

const card_types = "23456789TJQKA";

const Hand = struct {
    cards: []const u8,
    type: HandType,
};

const HandType = enum {
    HighCard,
    OnePair,
    TwoPair,
    ThreeOfAKind,
    FullHouse,
    FourOfAKind,
    FiveOfAKind,
};

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 6440;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
