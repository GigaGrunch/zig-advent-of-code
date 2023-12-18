const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var horizontal_edges = std.ArrayList(HorizontalEdge).init(allocator);
    var vertical_edges = std.ArrayList(VerticalEdge).init(allocator);
    defer {
        horizontal_edges.deinit();
        vertical_edges.deinit();
    }

    {
        var pos = Pos{ .x = 0, .y = 0 };

        var lines_it = utils.tokenize(text, "\r\n");
        while (lines_it.next()) |line| {
            var line_it = utils.tokenize(line, " ");
            const dir = line_it.next().?[0];
            const count = try utils.parseInt(i32, line_it.next().?);

            switch (dir) {
                'U' => {
                    pos.y -= count - 1;
                    try vertical_edges.append(.{ .start = pos, .length = count });
                    pos.y -= 1;
                },
                'D' => {
                    try vertical_edges.append(.{ .start = pos, .length = count });
                    pos.y += count;
                },
                'L' => {
                    pos.x -= count - 1;
                    try horizontal_edges.append(.{ .start = pos, .length = count });
                    pos.x -= 1;
                },
                'R' => {
                    try horizontal_edges.append(.{ .start = pos, .length = count });
                    pos.x += count;
                },
                else => unreachable,
            }
        }
    }

    std.debug.print("horizontal edges:\n", .{});
    for (horizontal_edges.items) |edge| std.debug.print("{}\n", .{edge});
    std.debug.print("vertical edges:\n", .{});
    for (vertical_edges.items) |edge| std.debug.print("{}\n", .{edge});

    return 0;
}

const HorizontalEdge = struct {
    start: Pos,
    length: i32,
};

const VerticalEdge = struct {
    start: Pos,
    length: i32,
};

const Pos = struct {
    x: i32,
    y: i32,
};

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 62;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
