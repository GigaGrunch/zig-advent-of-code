const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !u32 {
    _ = allocator;

    var horizontal_position: u32 = 0;
    var aim: u32 = 0;
    var depth: u32 = 0;

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        const command = try parseCommand(line);
        switch (command.type) {
            .Forward => {
                horizontal_position += command.value;
                depth += aim * command.value;
            },
            .Down => aim += command.value,
            .Up => aim -= command.value,
        }
    }

    return horizontal_position * depth;
}

fn parseCommand(line: []const u8) !Command {
    var split_it = utils.tokenize(line, " ");
    const type_string = split_it.next().?;
    const value_string = split_it.next().?;
    const value = try std.fmt.parseInt(u32, value_string, 10);

    var command = Command{ .value = value };

    if (std.mem.eql(u8, type_string, "forward")) {
        command.type = .Forward;
    } else if (std.mem.eql(u8, type_string, "down")) {
        command.type = .Down;
    } else if (std.mem.eql(u8, type_string, "up")) {
        command.type = .Up;
    } else unreachable;

    return command;
}

const Command = struct {
    type: enum { Forward, Down, Up } = undefined,
    value: u32,
};

test {
    const text = @embedFile("example.txt");
    const expected: u32 = 900;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
