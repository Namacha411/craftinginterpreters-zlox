const Scanner = @import("scanner.zig").Scanner;

pub fn compile(source: []const u8) void {
    var scanner = Scanner.init(source);
    var line = 0;
    while (true) {
        var token = scanner.scanToken();
        if (token.line != line) {
            std.debug.print("{d: >4}", .{token.line});
            line = token.line;
        } else {
            std.debug.print("{c: ^4}", .{'|'});
        }
        std.debug.print("{d: >2} '{s}'", .{token.type, token.start});
    }
}
