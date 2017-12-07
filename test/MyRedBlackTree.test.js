const MyRedBlackTree = artifacts.require("./MyRedBlackTree.sol");
const testHelper = require("./helpers/testHelper.js");
const ITEM_COUNT = 1000;
const DELETE_COUNT = 1000;
//const FIND_COUNT = 2;

let rbt;
before(async function() {
    this.timeout(100000);
    rbt = MyRedBlackTree.at(MyRedBlackTree.address);
});

contract("MyRedBlackTree tests", accounts => {
    it("insert x items", async function() {
        let val;
        for (let i=0; i < ITEM_COUNT; i++) {
            val = Math.floor((Math.random() * 30000) + 10000); // b/w 300 and 400 w 2 decimals
            let tx = await rbt.insert(i, val);
            testHelper.logGasUse(this, tx, "insert");
            console.log("inserted val: " + val + " id: " + i);
        }

    });

/*    it("find x items", async function() {
        for (let i=0; i < FIND_COUNT; i++) {
            let expId = Math.floor( Math.random() * ITEM_COUNT);
            let expItem = (await rbt.getItem(expId));
            let expVal = expItem[3].toNumber();

            let foundId = (await rbt.find(expVal)).toNumber();
            let foundItem = await rbt.getItem(foundId);
            let foundVal = foundItem[3].toNumber();
            console.log( expId, expVal, foundId, foundVal);
            assert.equal(expId, foundId, "foundId and expId should be the same");
            let findGas = await rbt.find.estimateGas(expVal);

            console.log(" find(" + val + ") gas: " + findGas);
        }
    });
    */

    it("remove x items", async function() {
        for (let i=0; i < DELETE_COUNT ; i++) {
            let id = Math.floor( Math.random() * (ITEM_COUNT - i));
            let tx = await rbt.remove(id);
            testHelper.logGasUse(this, tx, "remove");
        }
    });

});
