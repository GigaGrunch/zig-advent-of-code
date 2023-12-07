const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var hands = std.ArrayList(Hand).init(allocator);
    defer hands.deinit();

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        var parts_it = utils.tokenize(line, " ");
        const cards = parts_it.next().?;
        try hands.append(.{
            .cards = cards,
            .type = getType(cards),
            .bid = try utils.parseInt(i32, parts_it.next().?),
        });
    }

    std.mem.sort(Hand, hands.items, {}, strongerThan);

    for (hands.items) |hand| {
        std.debug.print("{} {s} {d}\n", .{ hand.type, hand.cards, hand.bid });
    }

    return 0;
}

fn getType(hand: []const u8) HandType {
    var counts = [_]i32{0} ** card_types.len;
    for (hand) |card| {
        const index = getCardIndex(card);
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

fn strongerThan(context: void, a: Hand, b: Hand) bool {
    _ = context;
    if (a.type != b.type) return @intFromEnum(a.type) > @intFromEnum(b.type);
    for (a.cards, b.cards) |a_card, b_card| {
        if (a_card != b_card) return getCardIndex(a_card) > getCardIndex(b_card);
    }
    return false;
}

const card_types = "23456789TJQKA";
fn getCardIndex(card: u8) usize {
    inline for (card_types, 0..) |card_type, index| {
        if (card == card_type) return index;
    }
    unreachable;
}

const Hand = struct {
    cards: []const u8,
    type: HandType,
    bid: i32,
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
