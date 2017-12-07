// based on: https://github.com/AtlantPlatform/rbt-solidity
pragma solidity ^0.4.18;

import "./RedBlackTree.sol";


contract MyRedBlackTree {
    using RedBlackTree for RedBlackTree.Tree;

    RedBlackTree.Tree public tree;

    function insert(uint64 id, uint value) public {
        require(value != 0);
        require(tree.items[id].value == 0);
        tree.insert(id, value);
    }

    function find(uint value) public view returns (uint64) {
        return tree.find(value);
    }

    function remove(uint64 id) public {
        tree.remove(id);
    }

    function getItem(uint64 id) public view returns (uint64 parent, uint64 left, uint64 right, uint value, bool red) {
        RedBlackTree.Item memory item = tree.items[id];
        parent = item.parent;
        left = item.left;
        right = item.right;
        value = item.value;
        red = item.red;
    }
}
