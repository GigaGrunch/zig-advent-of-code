const std = @import("std");
const utils = @import("utils");
const md5 = std.crypto.hash.Md5;

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var string = std.ArrayList(u8).init(allocator);
    defer string.deinit();

    var hash_string = std.ArrayList(u8).init(allocator);
    defer hash_string.deinit();

    var number: i32 = 1;
    while (true):(number += 1) {
        string.clearRetainingCapacity();
        hash_string.clearRetainingCapacity();

        try string.writer().print("{s}{d}", .{ text, number });

        var hash_buffer: [md5.digest_length]u8 = undefined;
        md5.hash(string.items, &hash_buffer, .{});

        try hash_string.writer().print("{s:0>32}", .{ std.fmt.fmtSliceHexLower(&hash_buffer) });
        
        if (std.mem.startsWith(u8, hash_string.items, "00000")) {
            return number;
        }
    }

    unreachable;
}

test "abcdef" {
    const expected: i32 = 609043;
    const result = try execute("abcdef", std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}

test "pqrstuv" {
    const expected: i32 = 1048970;
    const result = try execute("pqrstuv", std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
