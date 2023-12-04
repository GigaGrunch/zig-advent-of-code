const std = @import("std");

pub fn main(execute: anytype) !void {
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
