// based on https://github.com/AdrianClv/Ethereum_libraries
pragma solidity ^0.4.18;


library MaxHeap {
    /// @notice Returns the element with the maximum value
    /// @return The element with the maximum value
    function max(uint[] storage self) public constant returns(uint) {
        return self[0];
    }

    /// @notice Checks if the heap is empty
    /// @return True if there are no elements in the heap
    function isEmpty(uint[] storage self) public constant returns(bool) {
        return (self.length == 0);
    }

    /// @notice Inserts the element `elem` in the heap
    /// @param elem Element to be inserted
    function insert(uint[] storage self, uint elem) internal {
        uint idx = self.push(elem);
        shiftUp(self, idx - 1);
    }

    /// @notice Deletes the element with the maximum value
    function deleteMax(uint[] storage self) internal {
        deletePos(self, 0);
    }

    /// @notice Deletes the element in the position `pos`
    /// @param pos Position of the element to be deleted
    function deletePos(uint[] storage self, uint pos) internal {
        self[pos] = self[self.length - 1];
        delete self[self.length - 1];
        shiftDown(self, pos);
    }

    /* Private functions */
    // Move a element up in the tree
    // Used to restore heap condition after insertion
    function shiftUp(uint[] storage self, uint pos) private {
        uint copy = self[pos];

        while (pos != 1 && copy > self[pos / 2]) {
            self[pos] = self[pos / 2];
            pos = pos / 2;
        }
        self[pos] = copy;
    }

    // Move a element down in the tree
    // Used to restore heap condition after deletion
    function shiftDown(uint[] storage self, uint pos) private {
        uint copy = self[pos];
        bool isHeap = false;

        uint sibling = pos*2;
        while (sibling < self.length && !isHeap) {
            if (sibling != (self.length - 1) && self[sibling+1] > self[sibling])
                sibling++;
            if (self[sibling] > copy) {
                self[pos] = self[sibling];
                pos = sibling;
                sibling = pos*2;
            } else {
                isHeap = true;
            }
        }
        self[pos] = copy;
    }
}
