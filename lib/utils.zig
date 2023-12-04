const std = @import("std");

pub fn main(execute: *const fn ([]const u8, std.mem.Allocator) anyerror!i32) !void {
    const expected_zig_version = .{ .major = 0, .minor = 11, .patch = 0 };
    const compatible = comptime @import("builtin").zig_version.order(expected_zig_version) == .eq;
    if (!compatible) @compileError("Zig version 0.11.0 is required.");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var args = try std.process.argsAlloc(gpa.allocator());
    defer std.process.argsFree(gpa.allocator(), args);

    if (args.len != 2) {
        std.debug.print("Pass one input file.\n", .{});
        return;
    }

    const input_file = args[1];
    const text = try std.fs.cwd().readFileAlloc(gpa.allocator(), input_file, 100000);
    defer gpa.allocator().free(text);

    const result = try execute(text, gpa.allocator());
    std.debug.print("{d}\n", .{result});
}

pub fn tokenize(text: []const u8, delimiters: []const u8) std.mem.TokenIterator(u8, .any) {
    return std.mem.tokenizeAny(u8, text, delimiters);
}

pub fn parseInt(text: []const u8) !i32 {
    return try std.fmt.parseInt(i32, text, 10);
}

pub fn contains(haystack: anytype, needle: anytype) bool {
    for (haystack) |element| if (std.meta.eql(element, needle)) return true;
    return false;
}
