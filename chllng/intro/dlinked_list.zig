// **Task:**
// To get some practice with pointers, define a generic doubly linked list
// ~~of heap-allocated strings~~. Write functions to insert, find, and delete
// items from it. Test them.
//
// **Note:**
// Current implementation has major flaw due to the `seek()` function. It
// can not handle all the possible type comparisons in the search process.
// So be sure to use elementary types like numeric or bytes, but do not try
// to use strings!

const std = @import("std");

const mem = std.mem;
const Allocator = mem.Allocator;
const testing = std.testing;

/// This generic function defines doubly linked list with elements of
/// type `T`, which is defined at compilation time. It has methods to insert,
/// prepend, append, remove, pop and seek items (nodes) in it.
pub fn DoublyLinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            /// `Node` struct stores a value of predefined type and points to
            /// the previous and next nodes.
            value: T,
            previous: ?*Node = null,
            next: ?*Node = null,
        };

        /// `DoublyLinkedList` struct keeps track of the length of the list,
        /// first and last elements of it.
        len: usize = 0,
        first: ?*Node = null,
        last: ?*Node = null,

        const BeforeAfter = enum { before, after };
        const FirstLast = enum { first, last };

        /// This function inserts new node after an existing one, modifying
        /// the pointers and length of the list.
        ///
        /// Arguments:
        ///     existing: pointer to a node that already exists in the list;
        ///     new: pointer to a node to be inserted after the existing one;
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

        /// This function inserts new node before an existing one, modifying
        /// the pointers and length of the list.
        ///
        /// Arguments:
        ///     existing: pointer to a node that already exists in the list;
        ///     new: pointer to a node to be inserted before the existing one;
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

        /// Unifies `insertBefore()` and `insertAfter` to a single interface.
        ///
        /// Arguments:
        ///     existing: pointer to a node that already exists in the list;
        ///     new: pointer to a node to be inserted either before or after the
        ///         existing one;
        ///     direction: where to put the new node.
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

        /// Inserts a node at the beginning of the list.
        ///
        /// Arguments:
        ///     new: pointer to a node to be inserted at the beginning of the list.
        pub fn prepend(self: *Self, new: *Node) void {
            if (self.first) |fnode| self.insertBefore(fnode, new) else {
                self.first = new;
                self.last = new;
                new.previous = null;
                new.next = null;

                self.len += 1;
            }
        }

        /// Inserts a node at the end of the list.
        ///
        /// Arguments:
        ///     new: pointer to a node to be inserted at the end of the list.
        pub fn append(self: *Self, new: *Node) void {
            if (self.last) |lnode| {
                self.insertAfter(lnode, new);
            } else self.prepend(new);
        }

        /// Removes a given node from the list. Modifies pointers and reduces
        /// the list length by 1.
        ///
        /// Arguments:
        ///     node: pointer to a node to be removed.
        pub fn remove(self: *Self, node: *Node) void {
            if (node.previous) |pnode| pnode.next = node.next else {
                self.first = node.next;
            }

            if (node.next) |nnode| nnode.previous = node.previous else {
                self.last = node.previous;
            }

            self.len -= 1;
        }

        /// Calls remove on either first or last node. Returns the node
        /// removed.
        ///
        /// Arguments:
        ///     position: where from node should be popped.
        /// Returns:
        ///     node removed.
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

        /// Seeks for a node with a given value traversing the list forwards
        /// (from first to last).
        ///
        /// Arguments:
        ///     find: value to search for.
        /// Returns:
        ///     pointer to the node if found, null otherwise.
        pub fn seekForwards(self: *Self, find: T) ?*Node {
            var current = self.first orelse return null;
            if (current.value == find) return current else {
                while (current.next) |cnode| {
                    if (cnode.value == find) return cnode;
                    current = current.next.?;
                } else return null;
            }
        }

        /// Seeks for a node with a given value traversing the list forwards
        /// (from first to last).
        ///
        /// Arguments:
        ///     find: value to search for.
        /// Returns:
        ///     pointer to the node if found, null otherwise.
        pub fn seekBackwards(self: *Self, find: T) ?*Node {
            var current = self.last orelse return null;
            if (current.value == find) return current else {
                while (current.previous) |cnode| {
                    if (cnode.value == find) return cnode;
                    current = current.previous.?;
                } else return null;
            }
        }

        /// Unifies the `seekForwards` and `seekBackwards` to a single
        /// interface.
        ///
        /// Returns:
        ///     pointer to the node if found, null otherwise.
        pub fn seek(self: *Self, find: T, from: FirstLast) ?*Node {
            switch (from) {
                .last => return self.seekBackwards(find),
                .first => return self.seekForwards(find),
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
