const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var left_list = std.ArrayList(i32).init(allocator);
    var right_list = std.ArrayList(i32).init(allocator);
    defer left_list.deinit();
    defer right_list.deinit();

    const content = std.mem.bytesAsSlice(u8, buffer);
    var lines = std.mem.splitScalar(u8, content, '\n');

    while (lines.next()) |line| {
        if (std.mem.eql(u8, std.mem.trim(u8, line, " \t"), "")) continue;
        const delimiter = "   ";
        const delimiter_index = std.mem.indexOf(u8, line, delimiter);
        if (delimiter_index == null) continue;

        const left_part = line[0..delimiter_index.?];
        const right_part = line[delimiter_index.? + delimiter.len ..];

        const left = try std.fmt.parseInt(i32, left_part, 10);
        const right = try std.fmt.parseInt(i32, right_part, 10);

        try left_list.append(left);
        try right_list.append(right);
    }

    std.debug.print("Left List: {any}\n", .{left_list.items});
    std.debug.print("Right List: {any}\n", .{right_list.items});

    std.mem.sort(i32, left_list.items, {}, std.sort.asc(i32));
    std.mem.sort(i32, right_list.items, {}, std.sort.asc(i32));

    std.debug.print("Left List sorted: {any}\n", .{left_list.items});
    std.debug.print("Right List sorted: {any}\n", .{right_list.items});

    var total_distance: i32 = 0;
    for (0..left_list.items.len) |i| {
        const left = left_list.items[i];
        const right = right_list.items[i];
        total_distance += if (left > right) left - right else right - left;
    }
    std.debug.print("Total distance: {any}\n", .{total_distance});
}
