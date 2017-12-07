const MyRbt = artifacts.require("./MyRedBlackTree.sol");
const Rbt = artifacts.require("./RedBlackTree.sol");

module.exports = function(deployer) {
    deployer.deploy(Rbt);
    deployer.link(Rbt, MyRbt);
    deployer.deploy(MyRbt);
};
