const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = allocator;

    var sum: i32 = 0;

    var string_it = utils.tokenize(text, ",\r\n");
    while (string_it.next()) |string| {
        sum += calculateHash(string);
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

test "example.txt" {
    const text = @embedFile("example.txt");
    const expected: i32 = 145;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
