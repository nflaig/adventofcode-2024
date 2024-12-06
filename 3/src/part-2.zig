const std = @import("std");
const Regex = @import("regex").Regex;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    const multi_line = std.mem.bytesAsSlice(u8, buffer);

    var combined = try allocator.alloc(u8, multi_line.len);
    defer allocator.free(combined);

    var index: usize = 0;
    for (multi_line) |byte| {
        if (byte == '\n') continue;

        combined[index] = byte;
        index += 1;
    }

    var reMul = try Regex.compile(allocator, "mul\\((\\d{1,3}),(\\d{1,3})\\)");
    defer reMul.deinit();

    var reDo = try Regex.compile(allocator, "do\\(\\)");
    defer reDo.deinit();

    var reDont = try Regex.compile(allocator, "don't\\(\\)");
    defer reDont.deinit();

    var mul_enabled: bool = true;
    var sum: i32 = 0;
    var start_pos: usize = 0;

    while (start_pos < combined.len) {
        const slice = combined[start_pos..];

        const mulMatch = try reMul.captures(slice);
        if (mulMatch == null) break;

        const doMatch = try reDo.captures(slice);
        if (doMatch != null and doMatch.?.boundsAt(0).?.lower < mulMatch.?.boundsAt(0).?.lower) {
            mul_enabled = true;
        }

        const dontMatch = try reDont.captures(slice);
        if (dontMatch != null and dontMatch.?.boundsAt(0).?.lower < mulMatch.?.boundsAt(0).?.lower) {
            mul_enabled = false;
        }

        const captures = mulMatch.?;
        if (mul_enabled) {
            const num1 = try std.fmt.parseInt(i32, captures.sliceAt(1).?, 10);
            const num2 = try std.fmt.parseInt(i32, captures.sliceAt(2).?, 10);
            sum += num1 * num2;
        }

        start_pos += captures.boundsAt(0).?.upper;

        continue;
    }

    std.debug.print("Sum: {any}\n", .{sum});
}
