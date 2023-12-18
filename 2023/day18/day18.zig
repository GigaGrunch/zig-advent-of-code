const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var horizontal_edges = std.ArrayList(Edge).init(allocator);
    var vertical_edges = std.ArrayList(Edge).init(allocator);
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
                    var start = pos;
                    start.y -= count - 1;
                    var end = pos;
                    try vertical_edges.append(.{ .start = start, .end = end });
                    pos.y -= count;
                },
                'D' => {
                    var start = pos;
                    var end = pos;
                    end.y += count - 1;
                    try vertical_edges.append(.{ .start = start, .end = end });
                    pos.y += count;
                },
                'L' => {
                    var start = pos;
                    start.x -= count - 1;
                    var end = pos;
                    try horizontal_edges.append(.{ .start = start, .end = end });
                    pos.x -= count;
                },
                'R' => {
                    var start = pos;
                    var end = pos;
                    end.x += count - 1;
                    try horizontal_edges.append(.{ .start = start, .end = end });
                    pos.x += count;
                },
                else => unreachable,
            }
        }
    }

    for (horizontal_edges.items) |*horizontal_edge| {
        var left = horizontal_edge.start;
        left.x -= 1;
        var right = horizontal_edge.end;
        right.x += 1;

        for (vertical_edges.items) |*vertical_edge| {
            if (std.meta.eql(vertical_edge.start, right)) {
                horizontal_edge.end.x += 1;
                vertical_edge.start.y += 1;
            } else if (std.meta.eql(vertical_edge.start, left)) {
                horizontal_edge.start.x -= 1;
                vertical_edge.start.y += 1;
            }
        }
    }

    for (vertical_edges.items) |*vertical_edge| {
        var down = vertical_edge.end;
        down.y += 1;

        for (horizontal_edges.items) |*horizontal_edge| {
            if (std.meta.eql(horizontal_edge.start, down)) {
                vertical_edge.end.y += 1;
                horizontal_edge.start.x += 1;
            } else if (std.meta.eql(horizontal_edge.end, down)) {
                vertical_edge.end.y += 1;
                horizontal_edge.end.x -= 1;
            }
        }
    }

    var top_left = Pos{ .x = std.math.maxInt(i32), .y = std.math.maxInt(i32) };
    var bottom_right = Pos{ .x = std.math.minInt(i32), .y = std.math.minInt(i32) };

    for (horizontal_edges.items) |edge| {
        top_left.x = @min(top_left.x, edge.start.x);
        top_left.y = @min(top_left.y, edge.start.y);
        bottom_right.x = @max(bottom_right.x, edge.end.x);
        bottom_right.y = @max(bottom_right.y, edge.end.y);
    }

    for (vertical_edges.items) |edge| {
        top_left.x = @min(top_left.x, edge.start.x);
        top_left.y = @min(top_left.y, edge.start.y);
        bottom_right.x = @max(bottom_right.x, edge.end.x);
        bottom_right.y = @max(bottom_right.y, edge.end.y);
    }

    std.debug.print("{} .. {}\n", .{ top_left, bottom_right });

    std.mem.sort(Edge, vertical_edges.items, {}, moreLeft);

    for (horizontal_edges.items) |edge| std.debug.print("{}\n", .{edge});
    for (vertical_edges.items) |edge| std.debug.print("{}\n", .{edge});

    width = @intCast(bottom_right.x - top_left.x);
    height = @intCast(bottom_right.y - top_left.y);

    for (0..height + 1) |y_index| {
        for (0..width + 1) |x_index| {
            const y = @as(i32, @intCast(y_index)) + top_left.y;
            const x = @as(i32, @intCast(x_index)) + top_left.x;
            const pos = Pos{ .x = x, .y = y };

            var is_edge = false;

            for (horizontal_edges.items) |edge| {
                if (edge.contains(pos)) {
                    is_edge = true;
                    std.debug.print("-", .{});
                }
            }
            for (vertical_edges.items) |edge| {
                if (edge.contains(pos)) {
                    is_edge = true;
                    std.debug.print("|", .{});
                }
            }

            if (!is_edge) std.debug.print(".", .{});
        }
        std.debug.print("\n", .{});
    }

    for (0..height + 1) |y_index| {
        for (0..width + 1) |x_index| {
            const y = @as(i32, @intCast(y_index)) + top_left.y;
            const x = @as(i32, @intCast(x_index)) + top_left.x;
            const pos = Pos{ .x = x, .y = y };

            for (vertical_edges.items) |edge| {
                if (edge.contains(pos)) {
                    // TODO
                }
            }
        }
    }

    return 0;
}

var width: usize = undefined;
var height: usize = undefined;

fn moreLeft(_: void, a: Edge, b: Edge) bool {
    return a.start.x < b.start.x;
}

const Edge = struct {
    start: Pos,
    end: Pos,

    fn contains(edge: Edge, pos: Pos) bool {
        return pos.x >= edge.start.x and edge.end.x >= pos.x and
            pos.y >= edge.start.y and edge.end.y >= pos.y;
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
