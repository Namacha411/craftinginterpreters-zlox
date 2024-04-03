const std = @import("std");

const Chunk = @import("chunk.zig").Chunk;
const OpCode = @import("chunk.zig").OpCode;
const debug = @import("debug.zig");
const Vm = @import("vm.zig").Vm;
const InterpretResult = @import("vm.zig").InterpretResult;

const allocator = std.heap.page_allocator;

pub fn main() !void {
    var vm = Vm.init();
    defer vm.deinit();

    var args = try std.process.argsAlloc(allocator);
    if (args.len == 1) {
        repl();
    } else if (args.len == 2) {
        runFile(args[1]);
    } else {
        std.debug.print("Usage: zlox [path]\n", .{});
    }

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

fn repl(vm: *Vm) void {
    var line = [1024]u8{};
    var stdin = std.io.getStdIn();
    while (true) {
        std.debug.print("> ", .{});
        if (stdin.read(line) == 0) {
            std.debug.print("\n", .{});
            break;
        }
        vm.interpret(line);
    }
}

fn runFile(vm: *Vm, path: []const u8) !u8 {
    var source = readFile(path);
    var result = try vm.interpret(source);
    return switch (result) {
        InterpretResult.ok => 0,
        InterpretResult.compile_error => 65,
        InterpretResult.runtime_error => 70,
    };
}

fn readFile(path: []const u8) []u8 {
    var source = try std.fs.cwd().openFile(path, .{});
    defer source.close();

    var buf = [4096]u8{};
    var reader = std.io.bufferedReader(source.reader()).reader();
    reader.readAll(buf);
    return buf;
}
