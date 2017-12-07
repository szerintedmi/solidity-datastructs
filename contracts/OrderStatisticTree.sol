// based on https://github.com/drcode/ethereum-order-statistic-tree
pragma solidity ^0.4.18;


contract OrderStatisticTree {

    function insert(uint value) public {
        if (value == 0)
            nodes[value].dupes++;
        else {
            insertHelper(0, true, value);
        }
    }

    function remove(uint value) public {
        Node storage n = nodes[value];
        if (value == 0) {
            if (n.dupes == 0)
                return;
        } else {
            if (n.count == 0)
                return;
        }
        if (n.dupes > 0) {
            n.dupes--;
            if (value != 0)
                n.count--;
            fixParents(n.parent, n.side);
        } else
            removeHelper(value);
    }

    function rank(uint value) public view returns (uint smaller) {
        if (value != 0) {
            smaller = nodes[0].dupes;
            uint cur = nodes[0].children[true];
            Node storage curNode = nodes[cur];
            while (true) {
                if (cur <= value) {
                    if (cur < value)
                        smaller += 1 + curNode.dupes;
                    uint leftChild = curNode.children[false];
                    if (leftChild != 0)
                        smaller += nodes[leftChild].count;
                }
                if (cur == value)
                    break;
                cur = curNode.children[cur < value];
            }
        }
    }

    function selectAt(uint pos) public view returns (uint value) {
        uint zeroes = nodes[0].dupes;
        if (pos < zeroes)
            return 0;
        else {
            uint posNew = pos - zeroes;
            uint cur = nodes[0].children[true];
            Node storage curNode = nodes[cur];
            while (true) {
                uint left = curNode.children[false];
                uint curNum = curNode.dupes+1;
                if (left != 0) {
                    Node storage leftNode = nodes[left];
                    uint leftCount = leftNode.count;
                } else {
                    leftCount = 0;
                }
                if (posNew < leftCount) {
                    cur = left;
                    curNode = leftNode;
                } else if (posNew < leftCount + curNum) {
                    return cur;
                } else {
                    cur = curNode.children[true];
                    curNode = nodes[cur];
                    posNew -= leftCount + curNum;
                }
            }
        }
    }

    function duplicates(uint value) public view returns (uint n) {
        return nodes[value].dupes+1;
    }

    function count() public view returns (uint _count) {
        Node storage root = nodes[0];
        Node storage child = nodes[root.children[true]];
        return root.dupes + child.count;
    }

    function inTopN(uint value, uint n) public view returns (bool truth) {
        uint pos = rank(value);
        uint num = count();
        return (num - pos - 1 < n);
    }

    function percentile(uint value) public view returns (uint k) {
        uint pos = rank(value);
        uint same = nodes[value].dupes;
        uint num = count();
        return (pos * 100 + (same * 100 + 100) / 2) / num;
    }

    function atPercentile(uint _percentile) public view returns (uint value) {
        uint n = count();
        return selectAt(_percentile * n / 100);
    }

    function permille(uint value) public view returns (uint k) {
        uint pos = rank(value);
        uint same = nodes[value].dupes;
        uint num = count();
        return (pos * 1000 + (same * 1000 + 1000) / 2) / num;
    }

    function atPermille(uint _permille) public view returns (uint value) {
        uint n = count();
        return selectAt(_permille * n / 1000);
    }

    function median() public view returns (uint value) {
        return atPercentile(50);
    }

    function nodeLeftChild(uint value) public view returns (uint child) {
        child = nodes[value].children[false];
    }

    function nodeRighthCild(uint value) public view returns (uint child) {
        child = nodes[value].children[true];
    }

    function nodeParent(uint value) public view returns (uint parent) {
        parent = nodes[value].parent;
    }

    function nodeSide(uint value) public view returns (bool side) {
        side = nodes[value].side;
    }

    function nodeHeight(uint value) public view returns (uint height) {
        height = nodes[value].height;
    }

    function nodeCount(uint value) public view returns (uint _count) {
        _count = nodes[value].count;
    }

    function nodeDupes(uint value) public view returns (uint dupes) {
        dupes = nodes[value].dupes;
    }

    function updateCount(uint value) private {
        Node storage n = nodes[value];
        n.count = 1 + nodes[n.children[false]].count+nodes[n.children[true]].count + n.dupes;
    }

    function updateCounts(uint value) private {
        uint parent = nodes[value].parent;
        while (parent != 0) {
            updateCount(parent);
            parent = nodes[parent].parent;
        }
    }

    function updateHeight(uint value) private {
        Node storage n = nodes[value];
        uint heightLeft = nodes[n.children[false]].height;
        uint heightRight = nodes[n.children[true]].height;
        if (heightLeft > heightRight)
            n.height = heightLeft + 1;
        else
            n.height = heightRight + 1;
    }

    function balanceFactor(uint value) private view returns (int bf) {
        Node storage n = nodes[value];
        return int(nodes[n.children[false]].height) - int(nodes[n.children[true]].height);
    }

    function rotate(uint value, bool dir) private {
        bool otherDir = !dir;
        Node storage n = nodes[value];
        bool side = n.side;
        uint parent = n.parent;
        uint valueNew = n.children[otherDir];
        Node storage nNew = nodes[valueNew];
        uint orphan = nNew.children[dir];
        Node storage p = nodes[parent];
        Node storage o = nodes[orphan];
        p.children[side] = valueNew;
        nNew.side = side;
        nNew.parent = parent;
        nNew.children[dir] = value;
        n.parent = valueNew;
        n.side = dir;
        n.children[otherDir] = orphan;
        o.parent = value;
        o.side = otherDir;
        updateHeight(value);
        updateHeight(valueNew);
        updateCount(value);
        updateCount(valueNew);
    }

    function rebalanceInsert(uint nValue) private {
        updateHeight(nValue);
        Node storage n = nodes[nValue];
        uint pValue = n.parent;
        if (pValue != 0) {
            int pBf = balanceFactor(pValue);
            bool side = n.side;
            int sign;
            if (side)
                sign = -1;
            else
                sign = 1;
            if (pBf == sign * 2) {
                if (balanceFactor(nValue) == (-1 * sign))
                    rotate(nValue, side);
                rotate(pValue, !side);
            } else if (pBf != 0) rebalanceInsert(pValue);
        }
    }

    function rebalanceDelete(uint pValue, bool side) private {
        if (pValue != 0) {
            updateHeight(pValue);
            int pBf = balanceFactor(pValue);
            // bool dir=side;
            int sign;
            if (side)
                sign = 1;
            else
                sign = -1;
            int bf = balanceFactor(pValue);
            if (bf == (2 * sign)) {
                Node storage p = nodes[pValue];
                uint sValue = p.children[!side];
                int sBf = balanceFactor(sValue);
                if (sBf == (-1 * sign))
                    rotate(sValue, !side);
                rotate(pValue, side);
                if (sBf != 0) {
                    p = nodes[pValue];
                    rebalanceDelete(p.parent, p.side);
                }
            } else if (pBf != sign) {
                p = nodes[pValue];
                rebalanceDelete(p.parent, p.side);
            }
        }
    }

    function fixParents(uint parent, bool side) private {
        if (parent != 0) {
            updateCount(parent);
            updateCounts(parent);
            rebalanceDelete(parent, side);
        }
    }

    function insertHelper(uint pValue, bool side, uint value) private {
        Node storage root = nodes[pValue];
        uint cValue = root.children[side];
        if (cValue == 0) {
            root.children[side] = value;
            Node storage child = nodes[value];
            child.parent = pValue;
            child.side = side;
            child.height = 1;
            child.count = 1;
            updateCounts(value);
            rebalanceInsert(value);
        } else if (cValue == value) {
            nodes[cValue].dupes++;
            updateCount(value);
            updateCounts(value);
        } else {
            bool sideNew = (value >= cValue);
            insertHelper(cValue, sideNew, value);
        }
    }

    function rightmostLeaf(uint value) private view returns (uint leaf) {
        uint child = nodes[value].children[true];
        if (child != 0)
            return rightmostLeaf(child);
        else
            return value;
    }

    function zeroOut(uint value) private {
        Node storage n = nodes[value];
        n.parent = 0;
        n.side = false;
        n.children[false] = 0;
        n.children[true] = 0;
        n.count = 0;
        n.height = 0;
        n.dupes = 0;
    }

    function removeBranch(uint value, uint left, uint right) private {
        uint ipn = rightmostLeaf(left);
        Node storage i = nodes[ipn];
        uint dupes = i.dupes;
        removeHelper(ipn);
        Node storage n = nodes[value];
        uint parent = n.parent;
        Node storage p = nodes[parent];
        uint height = n.height;
        bool side = n.side;
        uint _count = n.count;
        right = n.children[true];
        left = n.children[false];
        p.children[side] = ipn;
        i.parent = parent;
        i.side = side;
        i.count = _count + dupes - n.dupes;
        i.height = height;
        i.dupes = dupes;
        if (left != 0) {
            i.children[false] = left;
            nodes[left].parent = ipn;
        }
        if (right != 0) {
            i.children[true] = right;
            nodes[right].parent = ipn;
        }
        zeroOut(value);
        updateCounts(ipn);
    }

    function removeHelper(uint value) private {
        Node storage n = nodes[value];
        uint parent = n.parent;
        bool side = n.side;
        Node storage p = nodes[parent];
        uint left = n.children[false];
        uint right = n.children[true];
        if ((left == 0) && (right == 0)) {
            p.children[side] = 0;
            zeroOut(value);
            fixParents(parent, side);
        } else if ((left != 0) && (right != 0)) {
            removeBranch(value, left, right);
        } else {
            uint child = left+right;
            Node storage c = nodes[child];
            p.children[side] = child;
            c.parent = parent;
            c.side = side;
            zeroOut(value);
            fixParents(parent, side);
        }
    }

    struct Node {
        mapping (bool => uint) children;
        uint parent;
        bool side;
        uint height;
        uint count;
        uint dupes;
    }

    mapping(uint => Node) public nodes;
}
