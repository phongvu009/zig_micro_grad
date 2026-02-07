const std = @import("std");

pub const Value = struct {
    const Self = @This();

    value: f64,
    grad: f64,
    label: ?[]const u8,
    alloc: *const std.mem.Allocator,

    //Constructor
    pub fn init(allocator: *const std.mem.Allocator, value: f64, label: ?[]const u8) *Self {
        //using Self instead of Value make it is easier to manage the code if need changed
        const self = try allocator.create(Self);
        //dereference: fill in value
        self.* = .{
            .value = value,
            .grad = 0.0,
            .label = label,
            .alloc = allocator,
        };

        return self;
    }

    //Destructor
    pub fn deinit(self: *Self) void {
        self.alloc.destroy(self);
    }
};
