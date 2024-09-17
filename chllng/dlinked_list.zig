const std = @import("std");

const mem = std.mem;
const Allocator = mem.Allocator;
const testing = std.testing;

pub fn DoublyLinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            value: T,
            previous: ?*Node = null,
            next: ?*Node = null,
        };

        len: usize = 0,
        first: ?*Node = null,
        last: ?*Node = null,

        const BeforeAfter = enum { before, after };
        const FirstLast = enum { first, last };

        pub fn insertAfter(self: *Self, existing: *Node, new: *Node) void {
            new.previous = existing;
            if (existing.next) |nnode| {
                new.next = nnode;
                nnode.previous = new;
            } else {
                existing.next = null;
                self.last = new;
            }
            existing.next = new;

            self.len += 1;
        }

        pub fn insertBefore(self: *Self, existing: *Node, new: *Node) void {
            new.next = existing;
            if (existing.previous) |pnode| {
                new.previous = pnode;
                pnode.next = new;
            } else {
                new.previous = null;
                self.first = new;
            }
            existing.previous = new;

            self.len += 1;
        }

        pub fn insert(
            self: *Self,
            existing: *Node,
            new: *Node,
            direction: BeforeAfter,
        ) void {
            switch (direction) {
                .before => self.insertBefore(existing, new),
                .after => self.insertAfter(existing, new),
            }
        }

        pub fn prepend(self: *Self, new: *Node) void {
            if (self.first) |fnode| self.insertBefore(fnode, new) else {
                self.first = new;
                self.last = new;
                new.previous = null;
                new.next = null;

                self.len += 1;
            }
        }

        pub fn append(self: *Self, new: *Node) void {
            if (self.last) |lnode| {
                self.insertAfter(lnode, new);
            } else self.prepend(new);
        }

        pub fn remove(self: *Self, node: *Node) void {
            if (node.previous) |pnode| pnode.next = node.next else {
                self.first = node.next;
            }

            if (node.next) |nnode| nnode.previous = node.previous else {
                self.last = node.previous;
            }

            self.len -= 1;
        }

        pub fn pop(self: *Self, position: FirstLast) ?*Node {
            switch (position) {
                .last => {
                    const last = self.last orelse return null;
                    self.remove(last);
                    return last;
                },
                .first => {
                    const first = self.first orelse return null;
                    self.remove(first);
                    return first;
                },
            }
        }

        pub fn seek(self: *Self, find: T, from: FirstLast) ?*Node {
            switch (from) {
                .last => return self.seekBackwards(find),
                .first => return self.seekForwards(find),
            }
        }

        pub fn seekForwards(self: *Self, find: T) ?*Node {
            var current = self.first orelse return null;
            if (current.value == find) return current else {
                while (current.next) |cnode| {
                    if (cnode.value == find) return cnode;
                    current = current.next.?;
                } else return null;
            }
        }

        pub fn seekBackwards(self: *Self, find: T) ?*Node {
            var current = self.last orelse return null;
            if (current.value == find) return current else {
                while (current.previous) |cnode| {
                    if (cnode.value == find) return cnode;
                    current = current.previous.?;
                } else return null;
            }
        }
    };
}

test "comprehensive DoublyLinkedList test" {
    const IntDoublyLinkedList = DoublyLinkedList(i32);
    const IntNode = IntDoublyLinkedList.Node;

    var idll = IntDoublyLinkedList{};
    var first_node = IntNode{ .value = 1 };
    var second_node = IntNode{ .value = 2 };
    var third_node = IntNode{ .value = 3 };
    var fourth_node = IntNode{ .value = 4 };

    idll.prepend(&second_node);
    idll.insert(&second_node, &third_node, .after);
    idll.insert(&second_node, &first_node, .before);
    idll.append(&fourth_node);

    try testing.expectEqual(4, idll.len);
    try testing.expectEqual(&first_node, idll.first.?);
    try testing.expectEqual(&fourth_node, idll.last.?);
    try testing.expectEqual(&second_node, idll.seek(2, .first).?);
    try testing.expectEqual(&third_node, idll.seek(3, .last).?);
    try testing.expectEqual(null, idll.seek(5, .first));
    try testing.expectEqual(&first_node, idll.pop(.first).?);
    try testing.expectEqual(&fourth_node, idll.pop(.last).?);

    idll.remove(idll.seek(2, .first).?);
    idll.remove(idll.seek(3, .last).?);

    try testing.expectEqual(0, idll.len);
    try testing.expectEqual(null, idll.pop(.last));
}
