const Ost = artifacts.require("./OrderStatisticTree.sol");
const testHelper = require("./helpers/testHelper.js");
const ITEM_COUNT = 1000;
const DELETE_COUNT = 100;
const SELECTAT_COUNT = 100;

let ost;
before(async function() {
    //this.timeout(100000);
    ost = Ost.at(Ost.address); //await Ost.new();
});

contract("OrderStatisticTree tests", accounts => {
    it("insert x item", async function() {
        let val;
        for (let i=0; i < ITEM_COUNT; i++) {
            val = Math.floor((Math.random() * 30000) + 10000); // b/w 300 and 400 w 2 decimals
            let tx = await ost.insert(val);
            testHelper.logGasUse(this, tx, "insert val: " + val);
            //let rank =  ost.rank(val, {gas: 3000000});
            //let rankGas = await ost.rank.estimateGas(val, {gas: 3000000});
            //let removeGas = await ost.remove.estimateGas(val, {gas: 3000000});
            console.log("val: " + val
            //    + " rank (gas): " + rank //+ " (" + rankGas + ")"
            //    + " removeGas: " + removeGas
            );

        }
        let count = await ost.count();
        let countGas = await ost.count.estimateGas();
        console.log(" **** count : " + count + " countGas: " + countGas);

    });

    it("selectAt", async function() {
        for (let i=0; i < SELECTAT_COUNT; i++) {
            let pos = Math.floor( Math.random() * ITEM_COUNT);
            let val = await ost.selectAt(pos);
            let selectAtGas = await ost.selectAt.estimateGas(pos);
            let dupes = await ost.nodeDupes(val);
            let dupesGas = await ost.nodeDupes.estimateGas(val);
            // let rank = await ost.rank(val, {gas: 3000000});
            // let rankGas = await ost.rank.estimateGas(val, {gas: 3000000});
            console.log(" selectAt(" + pos + ") gas: " + selectAtGas + " val: " + val
                + " dupes: " + dupes + " dupesGas: " + dupesGas
                // + " rank(val): " + rank + " rankGas:" + rankGas
             );
        }
    });

    it("delete items", async function() {
        for (let i=0; i < DELETE_COUNT ; i++) {
            let pos = Math.floor( Math.random() * (ITEM_COUNT - i));
            let val = await ost.selectAt(pos);
            let selectAtGas = await ost.selectAt.estimateGas(pos);
            let dupes = await ost.nodeDupes(val);
            let dupesGas = await ost.nodeDupes.estimateGas(val);
            let tx = await ost.remove(pos);
            testHelper.logGasUse(this, tx, "delete pos: " + pos + " val: " + val
                + " selectAt(" + pos + ") selectAtGas:" + selectAtGas
                + " dupes : " + dupes + " dupesGas: " + dupesGas);
        }
    });
});
