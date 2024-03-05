const std = @import("std");
const allocator = std.heap.page_allocator;

pub const Value = f64;

pub const OpCode = enum(u8) {
    constant,
    add,
    subtract,
    multiply,
    divide,
    negate,
    ret,
};

pub const Chunk = struct {
    code: std.ArrayList(u8),
    lines: std.ArrayList(usize),
    constants: std.ArrayList(Value),

    pub fn init() Chunk {
        return Chunk{
            .code = std.ArrayList(u8).init(allocator),
            .lines = std.ArrayList(usize).init(allocator),
            .constants = std.ArrayList(Value).init(allocator),
        };
    }

    pub fn write(self: *Chunk, byte: u8, line: usize) !void {
        try self.code.append(byte);
        try self.lines.append(line);
    }

    pub fn write_constant(self: *Chunk, value: Value, line: usize) !void {
        try self.write(@intFromEnum(OpCode.constant), line);
        try self.write(@intCast(self.constants.items.len), line);
        try self.constants.append(value);
    }

    pub fn deinit(self: *Chunk) void {
        self.code.deinit();
        self.constants.deinit();
    }
};
