const std = @import("std");

const directions = [_][2]isize{
    [2]isize{ -1, -1 },
    [2]isize{ -1, 1 },
    [2]isize{ 1, 1 },
    [2]isize{ 1, -1 },
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    const content = std.mem.bytesAsSlice(u8, buffer);

    var lines_iter = std.mem.splitSequence(u8, content, "\n");

    var lines = try allocator.alloc([]const u8, lines_iter.buffer.len);
    defer allocator.free(lines);

    var num_lines: usize = 0;
    while (lines_iter.next()) |line| {
        lines[num_lines] = line;
        num_lines += 1;
    }

    const row_count = num_lines;
    const col_count = lines[0].len;

    var answer: usize = 0;

    for (1..row_count - 1) |row| {
        for (1..col_count - 1) |col| {
            if (lines[row][col] == 'A') {
                var str_buffer: [4]u8 = undefined;
                var str: []u8 = str_buffer[0..0];
                var i: usize = 0;
                for (directions) |direction| {
                    str_buffer[i] = lines[@intCast(@as(isize, @intCast(row)) + direction[0])][@intCast(@as(isize, @intCast(col)) + direction[1])];
                    i += 1;
                }
                str = str_buffer[0..4];

                if (std.mem.eql(u8, str, "MMSS") or std.mem.eql(u8, str, "SSMM") or std.mem.eql(u8, str, "SMMS") or std.mem.eql(u8, str, "MSSM")) {
                    answer += 1;
                }
            }
        }
    }

    std.debug.print("{d}\n", .{answer});
}
