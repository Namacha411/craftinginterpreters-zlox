const std = @import("std");

const Chunk = @import("chunk.zig").Chunk;
const OpCode = @import("chunk.zig").OpCode;
const debug = @import("debug.zig");
const Vm = @import("vm.zig").Vm;

pub fn main() !void {
    var vm = Vm.init();
    defer vm.deinit();

    var chunk = Chunk.init();
    defer chunk.deinit();

    try chunk.write_constant(1.2, 123);
    try chunk.write_constant(3.4, 123);

    try chunk.write(@intFromEnum(OpCode.add), 123);

    try chunk.write_constant(5.6, 123);

    try chunk.write(@intFromEnum(OpCode.divide), 123);
    try chunk.write(@intFromEnum(OpCode.negate), 123);
    try chunk.write(@intFromEnum(OpCode.ret), 123);
    try debug.disassembleChunk(&chunk, "test chunk");

    _ = try vm.interpret(&chunk);
}
