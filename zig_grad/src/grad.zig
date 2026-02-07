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
    pub fn deinit(self: *Self) void {
        self.alloc.destroy(self);
    }
};
