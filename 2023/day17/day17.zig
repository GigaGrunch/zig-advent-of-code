const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !i32 {
    var map_list = std.ArrayList(i32).init(allocator);
    defer map_list.deinit();
    height = 0;

    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        height += 1;

        for (line) |char| {
            try map_list.append(char - '0');
        }
    }

    map = map_list.items;
    width = map.len / height;

    var frontier = std.ArrayList(State).init(allocator);
    defer frontier.deinit();

    var lowest_cost: i32 = std.math.maxInt(i32);
    try frontier.append(.{
        .x = 0,
        .y = 0,
        .run_length = 0,
        .cost = 0,
        .dir = .Right,
    });
    try frontier.append(.{
        .x = 0,
        .y = 0,
        .run_length = 0,
        .cost = 0,
        .dir = .Down,
    });

    var visited = std.ArrayList(State).init(allocator);
    defer visited.deinit();

    while (frontier.items.len > 0) {
        std.mem.sort(State, frontier.items, {}, higherDistance);

        var state = frontier.pop();
        try visited.append(state);

        if (state.x == width - 1 and state.y == height - 1) {
            lowest_cost = state.cost;
        } else {
            var next_states = [_]?State {
                state.turnLeft(),
                state.turnRight(),
                state.goStraight(),
            };

            for (next_states) |next_state| {
                if (next_state) |next| {
                    if (next.cost >= lowest_cost) continue;

                    if (for (visited.items) |*other| {
                        if (next.x == other.x and next.y == other.y and next.dir == other.dir and next.run_length == other.run_length) {
                            if (next.cost < other.cost) {
                                other.cost = next.cost;
                                try frontier.append(next);
                            }
                            break false;
                        }
                    } else true) {
                        try frontier.append(next);
                    }
                }
            }
        }
    }

    return lowest_cost;
}

fn higherCost(_: void, a: State, b: State) bool {
    return a.cost > b.cost;
}

fn higherDistance(_: void, a: State, b: State) bool {
    return distance(a) > distance(b);
}

fn distance(state: State) usize {
    return (width - 1 - state.x) + (height - 1 - state.y);
}

var map: []const i32 = undefined;
var width: usize = undefined;
var height: usize = undefined;

const State = struct {
    x: usize,
    y: usize,
    run_length: i32,
    cost: i32,
    dir: Direction,

    fn goStraight(state: State) ?State {
        if (state.run_length == 3) return null;

        var copy = state;

        if (copy.step()) {
            copy.run_length += 1;
            return copy;
        }

        return null;
    }

    fn turnLeft(state: State) ?State {
        var copy = state;
        copy.dir = switch (state.dir) {
            .Up => .Left,
            .Down => .Right,
            .Left => .Down,
            .Right => .Up,
        };

        if (copy.step()) {
            copy.run_length = 1;
            return copy;
        }

        return null;
    }

    fn turnRight(state: State) ?State {
        var copy = state;
        copy.dir = switch (state.dir) {
            .Up => .Right,
            .Down => .Left,
            .Left => .Up,
            .Right => .Down,
        };

        if (copy.step()) {
            copy.run_length = 1;
            return copy;
        }

        return null;
    }

    fn step(state: *State) bool {
        switch (state.dir) {
            .Up => {
                if (state.y == 0) return false;
                state.y -= 1;
            },
            .Down => {
                if (state.y == height - 1) return false;
                state.y += 1;
            },
            .Left => {
                if (state.x == 0) return false;
                state.x -= 1;
            },
            .Right => {
                if (state.x == width - 1) return false;
                state.x += 1;
            },
        }

        state.cost += map[state.y * width + state.x];
        return true;
    }
};

const Direction = enum {
    Up,
    Down,
    Left,
    Right,
};

test {
    const text = @embedFile("example.txt");
    const expected: i32 = 102;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
