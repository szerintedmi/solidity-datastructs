/*
TODO: should add orderId for easy safe delete, i.e. deletePos(id, pos)
    (no find by orderid is required?)
TODO: we could use a linked list for the heap instead of a pure array to save gas.
    bubbling up the value requires an SSTORE for each move. SSTORE is expensive.
    With linkedlist we could  find the place where we should bubble up and insert there…
    Not sure if we save at the end but worth a try

*/
pragma solidity ^0.4.18;


library OrderHeap {

    struct Order {
        address owner;
        int price;  // storing in signed int, giving up some range on price
                    // but this way can use same heap for min and max (by negating the price for sell orders)
        uint32 time; // enough to store unix epoch b/w year 1970 and 2106 (introducing year 2106 problem :) )\
        uint amount;
    }

    function gt(Order o1, Order o2) internal pure returns(bool isO1GreaterThanO2) {
        return (o1.price > o2.price ||
                    (o1.price == o2.price && o1.time < o2.time));
    }

    /// @notice Inserts the element `elem` in the heap
    /// @param elem Element to be inserted
    function insert(Order[] storage self, Order elem) internal {
        uint idx = self.push(elem);
        shiftUp(self, idx - 1);
    }

    /// @notice Deletes the element in the position `pos`
    /// @param pos Position of the element to be deleted
    function deletePos(Order[] storage self, uint pos) internal {
        if (pos < self.length - 1) {
            self[pos] = self[self.length - 1];
            shiftDown(self, pos);
        }
        delete self[self.length - 1];
        self.length--;
    }

    /* Private functions */
    // Move a element up in the tree
    // Used to restore heap condition after insertion
    function shiftUp(Order[] storage self, uint pos) private {
        Order memory copy = self[pos];

        while (pos != 0 && gt(copy, self[pos / 2])) {
            self[pos] = self[pos / 2];
            pos = pos / 2;
        }
        self[pos] = copy;
    }

    // Move a element down in the tree
    // Used to restore heap condition after last item moved to pos
    // but before deletion of last item
    function shiftDown(Order[] storage self, uint pos) private {
        Order memory copy = self[pos];
        bool isHeap = false;

        uint sibling = pos * 2;
        while (sibling < self.length - 1 && !isHeap) {
            if (sibling != (self.length - 1)
                    && gt(self[sibling + 1], self[sibling])
                )
                sibling++;
            if (gt(self[sibling], copy)) {
                self[pos] = self[sibling];
                pos = sibling;
                sibling = pos * 2;
            } else {
                isHeap = true;
            }
        }
        self[pos] = copy;
    }


}
