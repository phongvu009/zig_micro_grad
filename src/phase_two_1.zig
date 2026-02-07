const std = @import("std");

pub const Value = struct {
    //get reference Struct
    const Self = @This();

    value: f64,
    grad: f64,
    label: ?[]const u8,
    alloc: *const std.mem.Allocator,

    pub fn init(allocator: *const std.mem.Allocator, value: f64, label: ?[]const u8) !*Self {
        const self = try allocator.create(Self);

        self.* = .{ .value = value, .grad = 0.0, .label = label, .alloc = allocator };

        return self;
    }

    pub fn deinit(self: *Self) void {
        //after create self -> destroy
        self.alloc.destroy(self);
    }

    pub fn print(self: *const Self) void {
        std.debug.print("Value(value={d}, grad={d:.2}, label={?s})\n", .{ self.value, self.grad, self.label.? });
    }
};

pub fn add(allocator: *const std.mem.Allocator, v1: *Value, v2: *Value) !*Value {
    return try Value.init(allocator, v1.value + v2.value, "+");
}

test "creating instance Value" {
    const allocator = &std.testing.allocator;

    const a = try Value.init(allocator, 10.0, "a");

    std.debug.print("Value a is {d}\n", .{a.*.value});

    a.print();

    //clean up
    a.deinit();
}

test "addition operation" {
    const allocator = &std.testing.allocator;

    const a = try Value.init(allocator, 10.0, "a");
    const b = try Value.init(allocator, 5.0, "b");

    const c = try add(allocator, a, b);

    c.print();

    //clean-up
    a.deinit();
    b.deinit();
    c.deinit();
}
