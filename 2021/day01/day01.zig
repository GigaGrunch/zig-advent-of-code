const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !u32 {
    _ = allocator;

    var depths: [2000]u32 = undefined;
    var i: usize = 0;
    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        depths[i] = try std.fmt.parseInt(u32, line, 10);
        i += 1;
    }

    var increase_count: u32 = 0;

    var previous = getDepthSum(depths[0..3]);
    i = 1;
    while (i < 1998) : (i += 1) {
        const depth = getDepthSum(depths[i .. i + 3]);
        if (depth > previous) {
            increase_count += 1;
        }
        previous = depth;
    }

    return increase_count;
}

fn getDepthSum(window: []u32) u32 {
    return window[0] + window[1] + window[2];
}
