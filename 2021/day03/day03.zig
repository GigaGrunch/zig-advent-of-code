const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !u32 {
    var samples = std.ArrayList([]const u8).init(allocator);
    defer samples.deinit();

    try getSamples(text, &samples);
    // return try powerConsumption(samples.items, allocator);
    return try lifeSupportRating(samples.items, allocator);
}

fn getSamples(text: []const u8, samples: *std.ArrayList([]const u8)) !void {
    var lines_it = utils.tokenize(text, "\r\n");
    while (lines_it.next()) |line| {
        try samples.append(line);
    }
}

fn powerConsumption(samples: []const []const u8, allocator: std.mem.Allocator) !u32 {
    const sample_count = samples.len;
    const sample_length = samples[0].len;

    var one_counts = try allocator.alloc(u32, sample_length);
    @memset(one_counts, 0);
    var gamma_string = try allocator.alloc(u8, sample_length);
    var epsilon_string = try allocator.alloc(u8, sample_length);
    defer {
        allocator.free(one_counts);
        allocator.free(gamma_string);
        allocator.free(epsilon_string);
    }

    for (samples) |sample| {
        for (sample, one_counts) |char, *count| {
            if (char == '1') {
                count.* += 1;
            }
        }
    }

    for (one_counts, gamma_string, epsilon_string) |count, *gamma_char, *epsilon_char| {
        gamma_char.* = if (count > sample_count / 2) '1' else '0';
        epsilon_char.* = if (count > sample_count / 2) '0' else '1';
    }

    const gamma = try std.fmt.parseInt(u32, gamma_string[0..], 2);
    const epsilon = try std.fmt.parseInt(u32, epsilon_string[0..], 2);
    const power_consumption = gamma * epsilon;

    return power_consumption;
}

fn lifeSupportRating(samples: []const []const u8, allocator: std.mem.Allocator) !u32 {
    const sample_length = samples[0].len;

    var oxygen_candidates = std.ArrayList([]const u8).init(allocator);
    var co2_candidates = std.ArrayList([]const u8).init(allocator);
    defer {
        oxygen_candidates.deinit();
        co2_candidates.deinit();
    }

    for (samples) |sample| {
        try oxygen_candidates.append(sample);
        try co2_candidates.append(sample);
    }

    var digit_index: usize = 0;
    while (digit_index < sample_length) : (digit_index += 1) {
        if (oxygen_candidates.items.len > 1) {
            var one_count: u32 = 0;
            for (oxygen_candidates.items) |candidate| {
                if (candidate[digit_index] == '1') {
                    one_count += 1;
                }
            }
            const zero_count = oxygen_candidates.items.len - one_count;
            const needs_one = one_count >= zero_count;

            var i: usize = oxygen_candidates.items.len - 1;
            while (true) {
                const candidate = oxygen_candidates.items[i];
                if (needs_one != (candidate[digit_index] == '1')) {
                    _ = oxygen_candidates.swapRemove(i);
                }

                if (i == 0) {
                    break;
                }

                i -= 1;
            }
        }

        if (co2_candidates.items.len > 1) {
            var one_count: u32 = 0;
            for (co2_candidates.items) |candidate| {
                if (candidate[digit_index] == '1') {
                    one_count += 1;
                }
            }
            const zero_count = co2_candidates.items.len - one_count;
            const needs_one = one_count < zero_count;

            var i: usize = co2_candidates.items.len - 1;
            while (true) {
                const candidate = co2_candidates.items[i];
                if (needs_one != (candidate[digit_index] == '1')) {
                    _ = co2_candidates.swapRemove(i);
                }

                if (i == 0) {
                    break;
                }

                i -= 1;
            }
        }

        if (oxygen_candidates.items.len <= 1 and co2_candidates.items.len <= 1) {
            break;
        }
    }

    std.debug.assert(oxygen_candidates.items.len == 1);
    std.debug.assert(co2_candidates.items.len == 1);

    const oxygen = try std.fmt.parseInt(u32, oxygen_candidates.items[0], 2);
    const co2 = try std.fmt.parseInt(u32, co2_candidates.items[0], 2);
    const life_support_rating = oxygen * co2;

    return life_support_rating;
}

test {
    const text = @embedFile("example.txt");
    // const expected: u32 = 198;
    const expected: u32 = 230;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
