const std = @import("std");

pub const Value = struct {
    //using built-in fuction to get reference of this struct
    const Self = @This();

    value: f64,
    grad: f64 = 0.0,
    label: ?[]const u8 = null,
    //keep track of children
    children: ?[]*Value = null,
    //keep track of operation of parent node
    op: ?[]const u8 = null,

    alloc: *const std.mem.Allocator,

    pub fn init(allocator: *const std.mem.Allocator, value: f64, label: ?[]const u8) !*Self {
        //create memory in heap
        const self = try allocator.create(Self);

        self.* = .{
            .value = value,
            .label = label,
            .children = null, //child node has no children,
            .op = null,
            .alloc = allocator,
        };

        return self;
    }

    pub fn deinit(self: *Self) void {
        //self.children is optional ?
        // unwrap it
        // free the list
        if (self.children) |children| {
            self.alloc.free(children);
        }
        self.alloc.destroy(self);
    }

    pub fn print(self: *const Self) void {
        const label = self.label orelse "anon";
        const op = self.op orelse "none";
        std.debug.print("Value(value={d}, grad={d}, label={s}, op={s}", .{ self.value, self.grad, label, op });
        //check if any children, unwrap and do a for loop
        if (self.children) |children| {
            var first = true;
            std.debug.print(", children=[", .{});
            for (children) |child| {
                //add comma to every child not last one
                if (!first) std.debug.print(", ", .{});
                first = false;
                std.debug.print("{s}:{d}", .{ child.label orelse "anon", child.value });
            }
            std.debug.print("]\n", .{});
        } else {
            std.debug.print(", children=[]\n", .{});
        }
    }
};

pub fn add(allocator: *const std.mem.Allocator, v1: *Value, v2: *Value) !*Value {
    //if label is null/none, pass it as parameter
    const out = try Value.init(allocator, v1.value + v2.value, null);
    //set math operation for parent node
    out.op = "+";
    //allocate memory for the list of childen
    //keep track of children
    const children = try allocator.alloc(*Value, 2);
    children[0] = v1;
    children[1] = v2;
    out.children = children;

    return out;
}

pub fn mul(allocator: *const std.mem.Allocator, v1: *Value, v2: *Value) !*Value {
    const out = try Value.init(allocator, v1.value * v2.value, null);

    out.op = "*";

    const children = try allocator.alloc(*Value, 2);
    children[0] = v1;
    children[1] = v2;
    out.children = children;

    return out;
}

test "instance of value" {
    const allocator = &std.testing.allocator;

    const a = try Value.init(allocator, 15.0, "a");

    a.print();

    a.deinit();
}

test "add operation" {
    const allocator = &std.testing.allocator;

    const a = try Value.init(allocator, 10.0, "a");
    const b = try Value.init(allocator, 5.0, "b");

    const c = try add(allocator, a, b);

    c.print();

    a.deinit();
    b.deinit();
    c.deinit();
}

test "multiply operation" {
    const allocator = &std.testing.allocator;

    const a = try Value.init(allocator, 7.0, "a");
    const b = try Value.init(allocator, 3.0, "b");
    const x = try Value.init(allocator, 2.0, "x");

    // build small graph : (a+b)*x
    const sum = try add(allocator, a, b);
    sum.label = "sum";

    const product = try mul(allocator, sum, x);
    product.label = "product";

    product.print();

    //show
    // if (product.children) |children| {
    //     std.debug.print("{s} was created by {s} {s} {s}\n", .{product.label.?, children[0].label orelse "anon", product.op.?, children[1].label orelse "anon"});
    // }
    //

    product.deinit();
    sum.deinit();
    x.deinit();
    b.deinit();
    a.deinit();
}
