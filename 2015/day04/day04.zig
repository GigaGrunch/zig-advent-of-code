const std = @import("std");
const utils = @import("utils");
const md5 = std.crypto.hash.Md5;

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = allocator;

    var hash_buffer: [md5.digest_length]u8 = undefined;
    var string = [_]u8 {0} ** 1000;
    std.mem.copy(u8, &string, text);

    var number: i32 = 1;
    while (true):(number += 1) {
        const digits = std.fmt.formatIntBuf(string[text.len..], number, 10, .lower, .{});

        md5.hash(string[0..text.len + digits], &hash_buffer, .{});

        if (hash_buffer[0] == 0 and hash_buffer[1] == 0 and hash_buffer[2] == 0) {
            return number;
        }
    }

    unreachable;
}
