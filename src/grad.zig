const std = @import("std");

pub const Value = struct {
    const Self = @This(); //shortcut to refer to this struct type

    //Data fields
    value: f64,
    //keep track grad
    grad: f64 = 0.0, //option name
    label: ?[]const u8 = null,
    //Memory management
    // Store  ref to the allocator for cleanup
    alloc: *const std.mem.Allocator,

    //Constructor
    pub fn init(allocator: *const std.mem.Allocator, val: f64, label: ?[]const u8) !*Self {
        //create memory in heap  via allocator
        //create(Self): This tells the allocator: "Please find a spot in memory big enough to hold one Value struct."
        //The Result: It returns a Pointer to that memory (*Value).
        //try to indicate it may fail
        const self = try allocator.create(Self);

        // .* syntax is used for Dereferencing a Pointer.
        // Go to the memory address stored in self, and write this entire block of data into it."
        self.* = .{
            .value = val,
            .grad = 0.0,
            .label = label,
            .alloc = allocator,
        };

        //return pointer
        return self;
    }

    //clean-up memory
    //wihout *const , *Self: is mutable pointer
    pub fn deinit(self: *Self) void {
        self.alloc.destroy(self);
    }

    //help to debug
    //*const : Read-only pointer
    // Self -> const Self -> *const Self
    // from right to left : pointer to constant Self
    pub fn print(self: *const Self) void {
        std.debug.print("Value(label={?s}, value={}, grad={})", .{ self.label, self.value, self.grad });
    }
};

pub fn add(allocator: *const std.mem.Allocator, v1: *Value, v2: *Value) !*Value {
    return try Value.init(allocator, v1.value + v2.value, "+");
}

test "test simple addition" {
    //use special testing allocator
    const allocator = &std.testing.allocator;

    //create instance value
    const a = try Value.init(allocator, 10.0, "a");
    const b = try Value.init(allocator, 5.0, "b");
    // perform addition
    const c = try add(allocator, a, b);

    //try return void
    std.debug.print("Result is c label as {s} value is {d}\n", .{ c.label.?, c.value });

    try std.testing.expectEqual(@as(f64, 15.0), c.value);

    //clean-up
    std.log.info("Attemptin to deinit", .{});
    c.deinit();
    a.deinit();
    b.deinit();
    std.log.info("Succes", .{});
}
