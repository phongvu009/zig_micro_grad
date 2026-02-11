const std = @import("std");

pub const Value = struct {
    const Self = @This();

    value: f64,
    label: ?[]const u8 = null,
    grad: f64 = 0.0,
    children: ?[]*Value = null,
    op: ?[]const u8 = null,
    //Optional to have constant pointer to function or null
    // *const : constant pointer
    //
    _backward: ?*const fn (self: *Self) void = null,
    alloc: *const std.mem.Allocator,

    pub fn init(allocator: *const std.mem.Allocator, value: f64, label: ?[]const u8) !*Self {
        const self = try allocator.create(Self);
        self.* = .{ .value = value, .label = label, .children = null, .op = null, ._backward = null, .alloc = allocator };

        return self;
    }

    pub fn deinit(self: *Self) void {
        if (self.children) |children| {
            self.alloc.free(children);
        }

        self.alloc.destroy(self);
    }

    pub fn backward(self: *Self) !void {
        //create dynamc Array/List: automatically allocates more memoery as items are added into it
        //use Allocator to get memory
        var topo = std.ArrayList(*Value).init(self.alloc.*);
        defer topo.deinit();

        //create HashMap, use as a Set (Unique Collection)
        var visited = std.AutoArrayHashMap(*Value, void).init(self.alloc.*);
        defer visited.deinit();

        try buildTopo(self, &topo, &visited);

        //we need to set gradient of output to calculate gradient backward
        //dL/dL = 1
        //self.grad += other.data * out.grad
        //out.grad set as 1 to help calculate gradient self.grad/child
        self.grad = 1.0;

        //Process nodes in reverse topological order
        var i: usize = topo.items.len;
        while (i > 0) : (i -= 1) {
            const v = topo.items[i - 1];
            if (v._backward) |backward_fn| {
                backward_fn(v);
            }
        }
    }
};

fn buildTopo(v: *Value, topo: *std.ArrayList(*Value), visited: *std.AutoArrayHashMap(*Value, void)) !void {
    //Recursive call to visit/travel from top to bottom. DFS
    //At leaf, start append node to the Arrray/List backward to top

    //check: have node in visited
    //visited is a Set contain Pointer to Value Node
    if (visited.contains(v)) return;
    //if not  add it
    try visited.put(v, {});

    if (v.children) |children| {
        for (children) |child| {
            try buildTopo(child, topo, visited);
        }
    }

    try topo.append(v);
}

// ---Backward  Operation  ----
pub fn add_backward(self: *Value) void {
    //unwrap in parent node
    const children = self.children.?;
    //calcualte child node grad using prarent node grad
    children[0].grad += 1.0 * self.grad;
    children[1].grad += 1.0 * self.grad;
}

pub fn add(allocator: *const std.mem.Allocator, v1: *Value, v2: *Value) !*Value {
    const out = try Value.init(allocator, v1.value + v2.value, null);
    out.op = "+";
    //
    out._backward = add_backward;

    const children = try allocator.alloc(*Value, 2);
    children[0] = v1;
    children[1] = v2;
    out.children = children;
    return out;
}

test "Backward for Addition" {
    const allocator = &std.testing.allocator;

    const a = try Value.init(allocator, 2.0, "a");
    const b = try Value.init(allocator, 3.0, "b");

    const out = try add(allocator, a, b);
    out.label = "output";

    std.debug.print("Output of sum is {s}={d}\n", .{ out.label.?, out.value });

    // --- perform backprop ---
    try out.backward();

    std.debug.print(" dL/da: {d:.2}\n", .{a.grad});
    std.debug.print(" dL/db: {d:.2}\n", .{b.grad});

    out.deinit();
    b.deinit();
    a.deinit();
}
