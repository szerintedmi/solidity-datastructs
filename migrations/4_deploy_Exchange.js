const Exchange = artifacts.require("./Exchange.sol");
const OrderHeap = artifacts.require("./OrderHeap.sol");

module.exports = function(deployer) {
    deployer.deploy(OrderHeap);
    deployer.link(OrderHeap, Exchange);
    deployer.deploy(Exchange);
};
