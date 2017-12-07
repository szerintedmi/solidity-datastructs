var Ost = artifacts.require("./OrderStatisticTree.sol");

module.exports = function(deployer) {
    //deployer.link(SafeMath, Rates);
    deployer.deploy(Ost);
};
