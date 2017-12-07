const Mmh = artifacts.require("./MyMaxHeap.sol");
const MaxHeap = artifacts.require("./MaxHeap.sol");

module.exports = function(deployer) {
    deployer.link(MaxHeap, Mmh);
    deployer.deploy(Mmh);
};
