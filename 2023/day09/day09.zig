const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
	try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
	_ = text;
	_ = allocator;
	return 0;
}

test {
	const text = @embedFile("example.txt");
	const expected: i32 = 114;
	const result = try execute(text, std.testing.allocator);
	try std.testing.expectEqual(expected, result);
}
