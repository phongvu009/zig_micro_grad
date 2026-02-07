const std = @import("std");
const zigrad = @import("grad.zig");

pub fn main() !void {
    std.debug.print("this is debug mesage\n\n", .{});

    //get general purpose allocator (GPA)
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    //get allocator interface from GPA
    const allocator = gpa.allocator();

    //defer run at the end of the current scope
    defer {
        const status = gpa.deinit();
        if (status == .leak) std.debug.print("Memory leak detected!\n", .{});
    }

    //create value instance from Value Type
    const v = try zigrad.Value.init(&allocator, 10.5, "input_x");

    //ensure value is cleaned up when we are done.
    defer v.deinit();
    std.debug.print("Create Value : {s} = {d:.2}\n", .{ v.label.?, v.value });
}
