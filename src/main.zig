const std = @import("std");

const fs = std.fs;
const heap = std.heap;
const mem = std.mem;
const process = std.process;

const Allocator = mem.Allocator;

const config = @import("config.zig");

pub fn main(args: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    if (args.len > 1) {
        config.log(.info, config.usage_message);
        process.exit(64);
    } else if (args.len == 1) try runFile(args[0], allocator) else runPrompt();
}

pub fn runFile(absolute_path: []const u8, arena: Allocator) !void {
    const file = try std.fs.openFileAbsolute(absolute_path, .{});
    defer file.close();
    try file.seekTo(0);
    const contents = &try file.readToEndAlloc(arena, 8192);
    run(contents);
}

pub fn runPrompt() void {}

pub fn run(contents: []const u8) void {
    _ = contents;
}
