const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var ranges = std.ArrayList(Range).init(allocator);
    defer ranges.deinit();

    var lines_it = utils.tokenize(text, "\r\n");
    try parseSeeds(lines_it.next().?, &ranges);
    while (lines_it.next()) |line| {
        if (utils.containsItem(line, ':')) {
            std.debug.assert(utils.containsString(line, "map:"));
            try finalizeMap(ranges.items);
        } else {
            try applyMapping(line, &ranges);
        }
    }

    var min: i64 = std.math.maxInt(i64);
    for (ranges.items) |range| {
        min = @min(min, range.min);
    }

    return @intCast(min);
}

fn parseSeeds(text: []const u8, ranges: *std.ArrayList(Range)) !void {
    var outer_it = utils.tokenize(text, ":");
    std.debug.assert(utils.streql(outer_it.next().?, "seeds"));
    var numbers_it = utils.tokenize(outer_it.next().?, " ");
    while (numbers_it.next()) |min_string| {
        const length_string = numbers_it.next().?;
        const min = try parseInt(min_string);
        const length = try parseInt(length_string);
        const max = min + length;
        try ranges.append(.{
            .min = min,
            .max = max,
            .converted = false,
        });
    }
}

fn finalizeMap(ranges: []Range) !void {
    for (ranges) |*range| {
        range.converted = false;
    }
}

fn applyMapping(text: []const u8, ranges: *std.ArrayList(Range)) !void {
    var it = utils.tokenize(text, " ");
    const dest_start = try parseInt(it.next().?);
    const source_start = try parseInt(it.next().?);
    const length = try parseInt(it.next().?);

    const min = source_start;
    const max = source_start + length - 1;
    const offset = dest_start - source_start;

    var new_ranges = std.ArrayList(Range).init(ranges.allocator);
    defer new_ranges.deinit();

    for (ranges.items) |*range| {
        if (range.converted) continue;

        if (range.min >= min and range.max <= max) {
            range.min += offset;
            range.max += offset;
            range.converted = true;
        } else if (range.min >= min and range.min <= max) {
            try new_ranges.append(.{
                .min = max + 1,
                .max = range.max,
                .converted = false,
            });
            range.min += offset;
            range.max = max + offset;
            range.converted = true;
        } else if (range.max <= max and range.max >= min) {
            try new_ranges.append(.{
                .min = range.min,
                .max = min - 1,
                .converted = false,
            });
            range.min = min + offset;
            range.max += offset;
            range.converted = true;
        }
    }

    try ranges.appendSlice(new_ranges.items);
}

fn parseInt(text: []const u8) !i64 {
    return try std.fmt.parseInt(i64, text, 10);
}

const Range = struct {
    min: i64,
    max: i64,
    converted: bool,
};

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 46;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
