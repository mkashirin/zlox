// **Task:**
// Get a “Hello, world!” program written and running in ~~Java~~ Zig. Set up
// whatever makefiles or IDE projects you need to get it working. If you have a
// debugger, get comfortable with it and step through your program as it runs.

const std = @import("std");

pub fn main() void {
    std.debug.print("Hello, World!", .{});
}
