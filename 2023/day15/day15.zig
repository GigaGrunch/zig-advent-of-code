const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var boxes = [_]Box{.{ .lenses = std.ArrayList(Lens).init(allocator) }} ** 256;
    defer for (boxes) |box| box.lenses.deinit();

    var sum: i32 = 0;

    var text_it = utils.tokenize(text, ",\r\n");
    while (text_it.next()) |string| {
        const index = calculateHash(string);
        var box = &boxes[index];
        _ = box;

        var string_it = utils.tokenize(string, "=-");
        const label = string_it.next().?;

        if (utils.containsItem(string, '=')) {
            const focal_length = try utils.parseInt(i32, string_it.next().?);
            std.debug.print("box {d}, replace {s} with {d}\n", .{ index, label, focal_length });
        } else if (utils.containsItem(string, '-')) {
            std.debug.print("box {d}, remove {s}\n", .{ index, label });
        } else {
            unreachable;
        }
    }

    return sum;
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
