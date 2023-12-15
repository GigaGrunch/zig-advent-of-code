const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var boxes = [_]Box{.{ .lenses = std.ArrayList(Lens).init(allocator) }} ** 256;
    defer for (boxes) |box| box.lenses.deinit();

    var text_it = utils.tokenize(text, ",\r\n");
    while (text_it.next()) |string| {
        var string_it = utils.tokenize(string, "=-");
        const label = string_it.next().?;

        const index = calculateHash(label);
        var box = &boxes[index];

        if (utils.containsItem(string, '=')) {
            const focal_length = try utils.parseInt(i32, string_it.next().?);
            try put(box, label, focal_length);
        } else if (utils.containsItem(string, '-')) {
            remove(box, label);
        } else {
            unreachable;
        }
    }

    var sum: i32 = 0;

    for (boxes, 0..) |box, box_index| {
        for (box.lenses.items, 0..) |lens, lens_index| {
            const box_number: i32 = @intCast(box_index + 1);
            const lens_number: i32 = @intCast(lens_index + 1);
            sum += box_number * lens_number * lens.focal_length;
        }
    }

    return sum;
}

fn put(box: *Box, label: []const u8, focal_length: i32) !void {
    for (box.lenses.items) |*lens| {
        if (utils.streql(lens.label, label)) {
            lens.focal_length = focal_length;
            return;
        }
    }

    try box.lenses.append(.{ .label = label, .focal_length = focal_length });
}

fn remove(box: *Box, label: []const u8) void {
    var remove_index: ?usize = null;
    for (box.lenses.items, 0..) |lens, i| {
        if (utils.streql(lens.label, label)) {
            remove_index = i;
            break;
        }
    }

    if (remove_index) |i| {
        _ = box.lenses.orderedRemove(i);
    }
}

fn calculateHash(string: []const u8) u8 {
    var hash: i32 = 0;
    for (string) |char| {
        hash += char;
        hash *= 17;
        hash = @mod(hash, 256);
    }
    return @intCast(hash);
}

const Lens = struct {
    label: []const u8,
    focal_length: i32,
};

const Box = struct {
    lenses: std.ArrayList(Lens),
};

test "example.txt" {
    const text = @embedFile("example.txt");
    const expected: i32 = 145;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
