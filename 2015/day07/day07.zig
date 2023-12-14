const std = @import("std");
const utils = @import("utils");

var output_wire_name: []const u8 = "a";

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var wire_names = std.ArrayList([]const u8).init(allocator);
    var wire_values = std.ArrayList(u16).init(allocator);
    defer {
        wire_names.deinit();
        wire_values.deinit();
    }

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        var line_it = std.mem.split(u8, line, " -> ");
        const from = line_it.next().?;
        const to = line_it.next().?;
        const operator = parseOperator(from);
        std.debug.print("{} {s} -> {s}\n", .{ operator, from, to });
    }

    return 0;
}

fn parseOperator(string: []const u8) enum { And, Or, LShift, RShift, Not, Store } {
    if (utils.containsString(string, "AND")) return .And;
    if (utils.containsString(string, "OR")) return .Or;
    if (utils.containsString(string, "LSHIFT")) return .LShift;
    if (utils.containsString(string, "RSHIFT")) return .RShift;
    if (utils.containsString(string, "NOT")) return .Not;
    return .Store;
}

test "d" {
    try runTest("d", 72);
}

test "e" {
    try runTest("e", 507);
}

test "f" {
    try runTest("f", 492);
}

test "g" {
    try runTest("g", 114);
}

test "h" {
    try runTest("h", 65412);
}

test "i" {
    try runTest("i", 65079);
}

test "x" {
    try runTest("x", 123);
}

test "y" {
    try runTest("y", 456);
}

fn runTest(wire_name: []const u8, expected: i32) !void {
    output_wire_name = wire_name;
    const text = @embedFile("example.txt");
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
