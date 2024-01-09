const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    try utils.main(&execute);
}

fn execute(text: []const u8, allocator: std.mem.Allocator) !u32 {
    var lines_it = utils.tokenize(text, "\r\n");

    var draw_numbers = std.ArrayList(u7).init(allocator);
    defer draw_numbers.deinit();

    {
        var first_line_it = utils.tokenize(lines_it.next().?, ",");
        while (first_line_it.next()) |part| {
            try draw_numbers.append(try drawNumber(part));
        }
    }

    var last_board_index: usize = 127;
    var last_board_turn: u7 = 0;
    var last_board_score: u32 = 0;

    var board_index: usize = 0;
    while (lines_it.peek()) |_| {
        var board: [25]u7 = undefined;
        var draw_turns = [_]?u7{null} ** 25;
        {
            for (0..5) |row| {
                var numbers_it = utils.tokenize(lines_it.next().?, " ");
                for (0..5) |column| {
                    const i = row * 5 + column;
                    const num_string = numbers_it.next().?;

                    board[i] = try std.fmt.parseInt(u7, num_string, 10);

                    for (draw_numbers.items, 0..) |draw, turn| {
                        if (draw == board[i]) {
                            draw_turns[i] = @as(u7, @intCast(turn));
                            break;
                        }
                    }
                }
            }
        }

        var win_turn: u7 = 127;

        var o_winning_row: ?usize = null;
        {
            var row: usize = 0;
            while (row < 5) : (row += 1) {
                var o_row_win_turn: ?u7 = null;

                var column: usize = 0;
                while (column < 5) : (column += 1) {
                    const i = row * 5 + column;

                    if (draw_turns[i]) |turn| {
                        if (o_row_win_turn) |row_win_turn| {
                            o_row_win_turn = @max(turn, row_win_turn);
                        } else {
                            o_row_win_turn = turn;
                        }
                    } else {
                        o_row_win_turn = null;
                        break;
                    }
                }

                if (o_row_win_turn) |row_win_turn| {
                    if (row_win_turn < win_turn) {
                        win_turn = row_win_turn;
                        o_winning_row = row;
                    }
                }
            }
        }

        var o_winning_column: ?usize = null;
        {
            var column: usize = 0;
            while (column < 5) : (column += 1) {
                var o_column_win_turn: ?u7 = null;

                var row: usize = 0;
                while (row < 5) : (row += 1) {
                    const i = row * 5 + column;

                    if (draw_turns[i]) |turn| {
                        if (o_column_win_turn) |column_win_turn| {
                            o_column_win_turn = @max(turn, column_win_turn);
                        } else {
                            o_column_win_turn = turn;
                        }
                    } else {
                        o_column_win_turn = null;
                        break;
                    }
                }

                if (o_column_win_turn) |column_win_turn| {
                    if (column_win_turn < win_turn) {
                        win_turn = column_win_turn;
                        o_winning_row = null;
                        o_winning_column = column;
                    }
                }
            }
        }

        var score: u32 = 0;
        for (board, draw_turns) |num, draw_turn| {
            if (draw_turn == null or draw_turn.? > win_turn) {
                score += num;
            }
        }
        score *= draw_numbers.items[win_turn];

        if (win_turn > last_board_turn) {
            last_board_turn = win_turn;
            last_board_score = score;
            last_board_index = board_index;
        }

        board_index += 1;
    }

    return last_board_score;
}

fn drawNumber(string: []const u8) !u7 {
    return try std.fmt.parseInt(u7, string, 10);
}

test {
    const text = @embedFile("example.txt");
    const expected: u32 = 1924;
    const result = try execute(text, std.testing.allocator);
    try std.testing.expectEqual(expected, result);
}
