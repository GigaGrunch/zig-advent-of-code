const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !usize {
    var map_list = std.ArrayList(usize).init(allocator);
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

    var cost_frontier = std.ArrayList(usize).init(allocator);
    defer cost_frontier.deinit();

    var visited = std.AutoHashMap(State, usize).init(allocator);
    defer visited.deinit();

    var lowest_cost: usize = std.math.maxInt(usize);
    try frontier.append(.{
        .x = 0,
        .y = 0,
        .run_length = 0,
        .dir = .Right,
    });
    try cost_frontier.append(0);
    try frontier.append(.{
        .x = 0,
        .y = 0,
        .run_length = 0,
        .dir = .Down,
    });
    try cost_frontier.append(0);

    while (frontier.items.len > 0) {
        const state = frontier.pop();
        const cost = cost_frontier.pop();

        if (state.x == width - 1 and state.y == height - 1 and state.run_length >= 4) {
            if (cost < lowest_cost) {
                lowest_cost = cost;
            }
        } else {
            try visited.put(state, cost);

            var next_states = [_]?State{
                state.turnLeft(),
                state.turnRight(),
                state.goStraight(),
            };

            std.mem.sort(?State, &next_states, {}, greaterDistance);

            for (next_states) |next_state| {
                if (next_state) |next| {
                    const next_cost = cost + map[next.y * width + next.x];
                    const next_goal_distance = distance(next);

                    if (next_cost + next_goal_distance >= lowest_cost) continue;

                    if (visited.get(next)) |other_cost| {
                        if (next_cost < other_cost) {
                            try frontier.append(next);
                            try cost_frontier.append(next_cost);
                        }
                    } else {
                        try frontier.append(next);
                        try cost_frontier.append(next_cost);
                    }
                }
            }
        }
    }

    return lowest_cost;
}

fn greaterDistance(_: void, a: ?State, b: ?State) bool {
    const distance_a = if (a) |value_a| distance(value_a) else 0;
    const distance_b = if (b) |value_b| distance(value_b) else 0;
    return distance_a > distance_b;
}

fn insert(frontier: *std.ArrayList(State), cost_frontier: *std.ArrayList(usize), state: State, cost: usize) !void {
    const index = for (1..frontier.items.len) |i| {
        const other = frontier.items[i];
        const prev = frontier.items[i - 1];
        const state_distance = distance(state);
        const other_distance = distance(other);
        const prev_distance = distance(prev);
        if (prev_distance >= state_distance and state_distance >= other_distance) break i;
    } else frontier.items.len;
    try frontier.insert(index, state);
    try cost_frontier.insert(index, cost);
}

fn distance(state: State) usize {
    return (width - 1 - state.x) + (height - 1 - state.y);
}

var map: []const usize = undefined;
var width: usize = undefined;
var height: usize = undefined;

const State = struct {
    x: usize,
    y: usize,
    run_length: usize,
    dir: Direction,

    fn goStraight(state: State) ?State {
        if (state.run_length == 10) return null;

        var copy = state;

        if (copy.step()) {
            copy.run_length += 1;
            return copy;
        }

        return null;
    }

    fn turnLeft(state: State) ?State {
        if (state.run_length < 4) return null;

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
        if (state.run_length < 4) return null;

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

        return true;
    }
};

const Direction = enum {
    Up,
    Down,
    Left,
    Right,
};

test "example01" {
    const text = @embedFile("example01.txt");
    const expected: usize = 94;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}

test "example02" {
    const text = @embedFile("example02.txt");
    const expected: usize = 71;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
