const std = @import("std");

pub fn main(execute: anytype) !void {
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

pub fn parseInt(comptime T: type, text: []const u8) !T {
    return try std.fmt.parseInt(T, text, 10);
}

pub fn containsItem(haystack: anytype, needle: anytype) bool {
    for (haystack) |element| if (std.meta.eql(element, needle)) return true;
    return false;
}

pub fn containsString(haystack: []const u8, needle: []const u8) bool {
    return std.mem.containsAtLeast(u8, haystack, 1, needle);
}

pub fn startsWith(haystack: []const u8, needle: []const u8) bool {
    return std.mem.startsWith(u8, haystack, needle);
}

pub fn endsWith(haystack: []const u8, needle: []const u8) bool {
    return std.mem.endsWith(u8, haystack, needle);
}

pub fn streql(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

pub fn indexOf(haystack: anytype, needle: anytype) ?usize {
    for (haystack, 0..) |element, i| if (std.meta.eql(element, needle)) return i;
    return null;
}
