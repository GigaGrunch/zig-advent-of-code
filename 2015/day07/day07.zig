const std = @import("std");
const utils = @import("utils");

var output_wire_name: []const u8 = "a";

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = allocator;
    _ = text;
    return 0;
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
