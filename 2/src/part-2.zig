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
        const levels = std.mem.splitScalar(u8, line, ' ');

        const parsedLevels = try parseLevels(levels);

        if (isSafe(parsedLevels)) {
            safeCount += 1;
        } else {
            for (0..parsedLevels.len) |i| {
                const modifiedLevels = try removeLevel(parsedLevels, i);
                if (isSafe(modifiedLevels)) {
                    safeCount += 1;
                    break;
                }
            }
        }
    }

    std.debug.print("Safe count: {any}\n", .{safeCount});
}

fn parseLevels(levels: std.mem.SplitIterator(u8, .scalar)) ![]i32 {
    const allocator = std.heap.page_allocator;
    var list = std.ArrayList(i32).init(allocator);
    defer list.deinit();

    var mutableLevels = levels;

    while (mutableLevels.next()) |level| {
        try list.append(try std.fmt.parseInt(i32, level, 10));
    }

    return list.toOwnedSlice();
}

fn removeLevel(levels: []i32, index: usize) ![]i32 {
    const allocator = std.heap.page_allocator;
    var list = std.ArrayList(i32).init(allocator);
    defer list.deinit();

    for (0..levels.len) |i| {
        if (i != index) {
            try list.append(levels[i]);
        }
    }

    return list.toOwnedSlice();
}

fn isSafe(levels: []i32) bool {
    if (levels.len <= 1) return true;

    var previous = levels[0];
    var isIncreasing: ?bool = null;

    for (0..levels.len - 1) |i| {
        const current = levels[i + 1];
        if (current == previous) return false;

        if (current > previous) {
            if (isIncreasing == false) return false;
            isIncreasing = true;

            if (current - previous > 3) return false;
        } else {
            if (isIncreasing == true) return false;
            isIncreasing = false;

            if (previous - current > 3) return false;
        }

        previous = current;
    }

    return true;
}
