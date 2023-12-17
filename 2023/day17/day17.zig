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

    var lowest_cost: usize = std.math.maxInt(usize);
    try frontier.append(.{
        .x = 0,
        .y = 0,
        .run_length = 0,
        .cost = 0,
        .dir = .Right,
        .goal_distance = (width - 1) + (height - 1),
    });
    try frontier.append(.{
        .x = 0,
        .y = 0,
        .run_length = 0,
        .cost = 0,
        .dir = .Down,
        .goal_distance = (width - 1) + (height - 1),
    });

    var visited = std.AutoHashMap(Visited, usize).init(allocator);
    defer visited.deinit();

    while (frontier.items.len > 0) {
        var state = frontier.pop();
        try visited.put(Visited.init(state), state.cost);

        if (state.x == width - 1 and state.y == height - 1) {
            lowest_cost = state.cost;
            std.debug.print("new lowest: {d} ({d} left)\n", .{lowest_cost, frontier.items.len});
        } else {
            var next_states = [_]?State {
                state.turnLeft(),
                state.turnRight(),
                state.goStraight(),
            };

            for (next_states) |next_state| {
                if (next_state) |next| {
                    if (next.cost >= lowest_cost or next.cost + next.goal_distance >= lowest_cost) continue;

                    const next_visited = Visited.init(next);
                    if (visited.get(next_visited)) |other_cost| {
                        if (next.cost < other_cost) {
                            try visited.put(next_visited, next.cost);
                            try insert(&frontier, next);
                        }
                    } else {
                        try insert(&frontier, next);
                    }
                }
            }
        }
    }

    return lowest_cost;
}

const Visited = struct {
    x: usize,
    y: usize,
    dir: Direction,
    run_length: usize,

    fn init(state: State) Visited {
        return .{
            .x = state.x,
            .y = state.y,
            .dir = state.dir,
            .run_length = state.run_length,
        };
    }
};

fn insert(frontier: *std.ArrayList(State), state: State) !void {
    const index = for (frontier.items, 0..) |other, i| {
        if (state.goal_distance > other.goal_distance or state.goal_distance == other.goal_distance and state.cost > other.cost) break i;
    } else frontier.items.len;
    try frontier.insert(index, state);
}

fn highDistanceHighCostFirst(_: void, a: State, b: State) bool {
    return if (a.goal_distance == b.goal_distance) a.cost > b.cost else a.goal_distance > b.goal_distance;
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
    cost: usize,
    dir: Direction,
    goal_distance: usize,

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
        state.goal_distance = distance(state.*);
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
    const expected: usize = 102;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
