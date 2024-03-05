const std = @import("std");

const Chunk = @import("chunk.zig").Chunk;
const OpCode = @import("chunk.zig").OpCode;

pub fn disassembleChunk(chunk: *Chunk, name: []const u8) !void {
    std.debug.print("== {s} ==\n", .{name});
    var offset: usize = 0;
    while (offset < chunk.code.items.len) {
        offset = disassembleInstruction(chunk, offset);
    }
}

pub fn disassembleInstruction(chunk: *Chunk, offset: usize) usize {
    std.debug.print("{x:0>4} ", .{offset});
    if (0 < offset and chunk.lines.items[offset] == chunk.lines.items[offset - 1]) {
        std.debug.print("{c: >4} ", .{'|'});
    } else {
        std.debug.print("{d: >4} ", .{chunk.lines.items[offset]});
    }
    var instruction = chunk.code.items[offset];
    switch (instruction) {
        @intFromEnum(OpCode.ret) => {
            return simpleInstruction("OP_RETURN", offset);
        },
        @intFromEnum(OpCode.negate) => {
            return simpleInstruction("OP_NEGATE", offset);
        },
        @intFromEnum(OpCode.add) => {
            return simpleInstruction("OP_ADD", offset);
        },
        @intFromEnum(OpCode.subtract) => {
            return simpleInstruction("OP_SUBTRACT", offset);
        },
        @intFromEnum(OpCode.multiply) => {
            return simpleInstruction("OP_MULTIPLY", offset);
        },
        @intFromEnum(OpCode.divide) => {
            return simpleInstruction("OP_DIVIDE", offset);
        },
        @intFromEnum(OpCode.constant) => {
            return constantInstruction("OP_CONSTANT", chunk, offset);
        },
        else => {
            std.debug.print("Unknown opcode {}\n", .{instruction});
            return offset + 1;
        },
    }
}

fn simpleInstruction(name: []const u8, offset: usize) usize {
    std.debug.print("{s: <16}\n", .{name});
    return offset + 1;
}

fn constantInstruction(name: []const u8, chunk: *Chunk, offset: usize) usize {
    var constant = chunk.code.items[offset + 1];
    std.debug.print("{s: <16} {x:0>4} '{}'\n", .{
        name,
        constant,
        chunk.constants.items[constant],
    });
    return offset + 2;
}
