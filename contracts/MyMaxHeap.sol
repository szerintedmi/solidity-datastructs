pragma solidity ^0.4.18;


import "./MaxHeap.sol";


contract MyMaxHeap {
    uint[] public heap;
    using MaxHeap for uint[];

    function insert(uint val) public {
        heap.insert(val);
    }

    function deleteMax() public {
        heap.deleteMax();
    }

    function deletePos(uint pos) public {
        heap.deletePos(pos);
    }
}
