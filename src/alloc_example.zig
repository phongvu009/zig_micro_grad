const std = @import("std");

pub fn main() !void {
    //set-up allocator
    //(.{}) passing default setting
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //make sure clean up when out of main scope
    defer _ = gpa.deinit();
    //getting allocator interface
    const allocator = gpa.allocator();

    const count: usize = 5;
    //this return Slice (u32) - it allocates memory in heap
    //it will create 5 continos block of type u32(32-bit unsigned interger)
    //or u32 is 4 bytes, 4x5 = 20 bytes
    const my_numbers = try allocator.alloc(u32, count);
    //clean
    defer allocator.free(my_numbers);

    //loop through and assin value
    //each item is memory address
    // num : give me a copy
    // *num: give me the address
    for (my_numbers, 0..) |*num, i| {
        // derederence num.*
        num.* = @intCast((i + 1) * 10);
    }

    //show address and value after fill-in
    //we can not do &my_nubmers -> it will loop through address of itself
    //while we want to loop through is point to the container
    for (my_numbers) |*num| {
        std.debug.print("Pointer: {*} has value : {d}\n", .{ num, num.* });
    }

    //this is to read value only |num|
    for (my_numbers) |num| {
        std.debug.print("Value is : {d}\n", .{num});
    }
}
