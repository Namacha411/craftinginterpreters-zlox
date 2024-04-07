const std = @import("std");
const allocator = std.heap.page_allocator;

const Chunk = @import("chunk.zig").Chunk;
const OpCode = @import("chunk.zig").OpCode;
const debug = @import("debug.zig");
const Vm = @import("vm.zig").Vm;
const InterpretResult = @import("vm.zig").InterpretResult;

fn repl(vm: *Vm) !void {
    const stdout = std.io.getStdOut();
    const stdin = std.io.getStdIn();
    var buf: [1024]u8 = undefined;
    while (true) {
        try stdout.writer().print("> ", .{});
        if (stdin.reader().readUntilDelimiterOrEof(&buf, '\n')) |val| {
            var line: []const u8 = val.?;
            _ = try vm.interpret(line);
        } else |_| {
            try stdout.writer().print("\n", .{});
            break;
        }
    }
}

fn runFile(vm: *Vm, path: []const u8) !u8 {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var source: [1 << 16]u8 = undefined;
    _ = try file.readAll(&source);

    var result = try vm.interpret(&source);
    return switch (result) {
        InterpretResult.ok => 0,
        InterpretResult.compile_error => 65,
        InterpretResult.runtime_error => 70,
    };
}

pub fn main() !void {
    var vm = Vm.init();
    defer vm.deinit();

    const args = try std.process.argsAlloc(allocator);
    if (args.len == 1) {
        try repl(&vm);
    } else if (args.len == 2) {
        _ = try runFile(&vm, args[1]);
    } else {
        std.debug.print("Usage: zlox [path]\n", .{});
    }
}
