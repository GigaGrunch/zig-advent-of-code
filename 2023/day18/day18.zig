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

    var top_left = Pos{ .x = std.math.maxInt(i32), .y = std.math.maxInt(i32) };
    var bottom_right = Pos{ .x = std.math.minInt(i32), .y = std.math.minInt(i32) };

    for (horizontal_edges.items) |edge| {
        const min_x = edge.start.x;
        const max_x = edge.start.x + edge.length;
        const y = edge.start.y;

        top_left.x = @min(top_left.x, min_x);
        top_left.y = @min(top_left.y, y);
        bottom_right.x = @max(bottom_right.x, max_x);
        bottom_right.y = @max(bottom_right.y, y);
    }

    for (vertical_edges.items) |edge| {
        const x = edge.start.x;
        const min_y = edge.start.y;
        const max_y = edge.start.y + edge.length;

        top_left.x = @min(top_left.x, x);
        top_left.y = @min(top_left.y, min_y);
        bottom_right.x = @max(bottom_right.x, x);
        bottom_right.y = @max(bottom_right.y, max_y);
    }

    std.debug.print("{} .. {}\n", .{ top_left, bottom_right });

    for (horizontal_edges.items) |edge| std.debug.print("{}\n", .{edge});
    for (vertical_edges.items) |edge| std.debug.print("{}\n", .{edge});

    width = @intCast(bottom_right.x - top_left.x);
    height = @intCast(bottom_right.y - top_left.y);

    for (0..height) |y_index| {
        for (0..width) |x_index| {
            const y = @as(i32, @intCast(y_index)) + top_left.y;
            const x = @as(i32, @intCast(x_index)) + top_left.x;
            const pos = Pos{ .x = x, .y = y };

            var is_edge = false;

            for (horizontal_edges.items) |edge| {
                if (edge.contains(pos)) {
                    is_edge = true;
                }
            }
            for (vertical_edges.items) |edge| {
                if (edge.contains(pos)) {
                    is_edge = true;
                }
            }

            const char: u8 = if (is_edge) '#' else '.';
            std.debug.print("{c}", .{char});
        }
        std.debug.print("\n", .{});
    }

    return 0;
}

var width: usize = undefined;
var height: usize = undefined;

const HorizontalEdge = struct {
    start: Pos,
    length: i32,

    fn contains(edge: HorizontalEdge, pos: Pos) bool {
        return edge.start.y == pos.y and pos.x >= edge.start.x and edge.start.x + edge.length > pos.x;
    }
};

const VerticalEdge = struct {
    start: Pos,
    length: i32,

    fn contains(edge: VerticalEdge, pos: Pos) bool {
        return edge.start.x == pos.x and pos.y >= edge.start.y and edge.start.y + edge.length > pos.y;
    }
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
