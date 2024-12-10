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
    var lines = std.mem.splitScalar(u8, content, '\n');

    var safeCount: i32 = 0;

    while (lines.next()) |line| {
        var levels = std.mem.splitScalar(u8, line, ' ');

        var previous: ?i32 = null;
        var isIncreasing: ?bool = null;
        var isSafe: bool = true;
        while (levels.next()) |level| {
            const current = try std.fmt.parseInt(i32, level, 10);

            if (previous == null) {
                previous = current;
                continue;
            }

            if (current == previous.?) {
                isSafe = false;
                break;
            }

            if (current > previous.?) {
                if (isIncreasing == false) {
                    isSafe = false;
                    break;
                }
                isIncreasing = true;

                const distance = current - previous.?;
                if (distance > 3) {
                    isSafe = false;
                    break;
                }

                previous = current;
                continue;
            }

            if (previous.? > current) {
                if (isIncreasing == true) {
                    isSafe = false;
                    break;
                }
                isIncreasing = false;

                const distance = previous.? - current;
                if (distance > 3) {
                    isSafe = false;
                    break;
                }

                previous = current;
                continue;
            }
        }

        if (isSafe == true) {
            safeCount += 1;
        }
    }

    std.debug.print("Safe count: {any}\n", .{safeCount});
}
