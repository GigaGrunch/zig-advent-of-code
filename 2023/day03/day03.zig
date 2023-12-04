const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var lines_it = std.mem.tokenizeAny(u8, text, "\r\n");
    while (lines_it.next()) |line| {
        try lines.append(line);
    }

    var numbers = std.ArrayList(Number).init(allocator);
    defer numbers.deinit();

    var gears = std.ArrayList(Gear).init(allocator);
    defer gears.deinit();

    var current_number: ?Number = null;
    for (lines.items, 0..) |line, line_index| {
        for (line, 0..) |char, char_index| {
            switch (char) {
                '0'...'9' => {
                    if (current_number) |*number| {
                        number.end = char_index;
                    } else {
                        current_number = Number{
                            .line = line_index,
                            .start = char_index,
                            .end = char_index,
                        };
                    }
                },
                '*' => {
                    if (finalizeNumber(&current_number)) |number| try numbers.append(number);
                    const gear = Gear{
                        .line = line_index,
                        .pos = char_index,
                    };
                    try gears.append(gear);
                },
                else => if (finalizeNumber(&current_number)) |number| try numbers.append(number),
            }
        }

        if (finalizeNumber(&current_number)) |number| try numbers.append(number);
    }

    for (numbers.items) |*number| {
        for (gears.items) |*gear| {
            if (gear.line + 1 < number.line) continue;
            if (gear.line > number.line + 1) break;

            if (gear.line == number.line and (gear.pos + 1 == number.start or gear.pos == number.end + 1) or
                (gear.line + 1 == number.line or gear.line == number.line + 1) and (gear.pos + 1 >= number.start and gear.pos <= number.end + 1))
            {
                if (gear.number_count < 3) {
                    gear.numbers[gear.number_count] = number;
                    gear.number_count += 1;
                }
            }
        }
    }

    var sum: i32 = 0;
    for (gears.items) |gear| {
        if (gear.number_count == 2) {
            sum += try gear.numbers[0].parse(lines.items) * try gear.numbers[1].parse(lines.items);
        }
    }

    return sum;
}

fn finalizeNumber(number: *?Number) ?Number {
    defer number.* = null;
    return number.*;
}

const Number = struct {
    line: usize,
    start: usize,
    end: usize,

    fn parse(self: Number, lines: []const []const u8) !i32 {
        return try std.fmt.parseInt(i32, lines[self.line][self.start .. self.end + 1], 10);
    }
};

const Gear = struct {
    line: usize,
    pos: usize,
    numbers: [3]*Number = undefined,
    number_count: u32 = 0,
};

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 467835;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
