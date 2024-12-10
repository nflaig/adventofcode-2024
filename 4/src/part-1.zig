const std = @import("std");

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

    const word = "XMAS";
    var answer: usize = 0;

    for (0..row_count) |row| {
        for (0..col_count) |col| {
            if (lines[row][col] == 'X') {
                for (0..3) |drowi| {
                    for (0..3) |dcoli| {
                        const drow: isize = @as(isize, @intCast(drowi)) - 1;
                        const dcol: isize = @as(isize, @intCast(dcoli)) - 1;
                        if (drow == 0 and dcol == 0) {
                            continue;
                        }
                        var match: bool = true;
                        for (0..4) |i| {
                            const r2 = @as(isize, @intCast(row)) + drow * @as(isize, @intCast(i));
                            const c2 = @as(isize, @intCast(col)) + dcol * @as(isize, @intCast(i));
                            if (0 <= r2 and r2 < row_count and 0 <= c2 and c2 < col_count and lines[@intCast(r2)][@intCast(c2)] == word[i]) {} else {
                                match = false;
                                break;
                            }
                        }
                        if (match == true) {
                            answer += 1;
                        }
                    }
                }
            }
        }
    }

    std.debug.print("{d}\n", .{answer});
}
