const std = @import("std");
const allocator = std.heap.page_allocator;

const is_debug = (@import("builtin").mode == std.builtin.OptimizeMode.Debug);

const Chunk = @import("chunk.zig").Chunk;
const Value = @import("chunk.zig").Value;
const OpCode = @import("chunk.zig").OpCode;
const compile = @import("compiler.zig").compile;
const debug = @import("debug.zig");

pub const InterpretResult = enum {
    ok,
    compile_error,
    runtime_error,
};

pub const Vm = struct {
    chunk: ?*Chunk,
    code: ?[]const u8,
    ip: usize,
    stack: std.ArrayList(Value),

    pub fn init() Vm {
        return Vm{
            .chunk = null,
            .code = null,
            .ip = 0,
            .stack = std.ArrayList(Value).init(allocator),
        };
    }

    pub fn deinit(self: *Vm) void {
        _ = self;
    }

    pub fn interpret(self: *Vm, source: []const u8) !InterpretResult {
        _ = self;
        compile(source);
        return InterpretResult.ok;
    }

    fn readByte(self: *Vm) u8 {
        var ret = self.code.?[self.ip];
        self.ip += 1;
        return ret;
    }

    fn readConstant(self: *Vm) Value {
        return self.chunk.?.constants.items[self.readByte()];
    }

    fn add(a: Value, b: Value) Value {
        return a + b;
    }
    fn sub(a: Value, b: Value) Value {
        return a - b;
    }
    fn mul(a: Value, b: Value) Value {
        return a * b;
    }
    fn div(a: Value, b: Value) Value {
        return a / b;
    }

    fn binaryOp(self: *Vm, comptime op: fn (Value, Value) Value) !void {
        var a = self.stack.pop();
        var b = self.stack.pop();
        try self.stack.append(op(a, b));
    }

    fn run(self: *Vm) !InterpretResult {
        while (true) {
            if (is_debug) {
                std.debug.print("Stack Trace: ", .{});
                for (self.stack.items) |value| {
                    std.debug.print("[{}]", .{value});
                }
                std.debug.print("\n", .{});
                _ = debug.disassembleInstruction(self.chunk.?, self.ip);
            }
            var instruction = self.readByte();
            switch (instruction) {
                @intFromEnum(OpCode.ret) => {
                    std.debug.print("{}\n", .{self.stack.pop()});
                    return InterpretResult.ok;
                },
                @intFromEnum(OpCode.add) => {
                    try self.binaryOp(add);
                },
                @intFromEnum(OpCode.subtract) => {
                    try self.binaryOp(sub);
                },
                @intFromEnum(OpCode.multiply) => {
                    try self.binaryOp(mul);
                },
                @intFromEnum(OpCode.divide) => {
                    try self.binaryOp(div);
                },
                @intFromEnum(OpCode.negate) => {
                    try self.stack.append(-self.stack.pop());
                },
                @intFromEnum(OpCode.constant) => {
                    var constant = self.readConstant();
                    try self.stack.append(constant);
                },
                else => {},
            }
        }
        return InterpretResult.runtime_error;
    }
};
