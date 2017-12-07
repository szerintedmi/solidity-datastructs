const MaxHeap = artifacts.require("./MaxHeap.sol");
// var OrdersLib = artifacts.require("./OrdersLib.sol");

module.exports = function(deployer) {
    deployer.deploy(MaxHeap);
    // deployer.deploy(OrdersLib);
};
