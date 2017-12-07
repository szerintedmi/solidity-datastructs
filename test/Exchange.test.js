const Exchange = artifacts.require("./Exchange.sol");
const testHelper = require("./helpers/testHelper.js");
const exHelper = require("./helpers/exchangeTestHelper.js");
const ITEM_COUNT = 100;
const DELETE_COUNT = 10;
const ONEWEI =  web3.toWei(1);
const ETHROUND = 100000000000; // 6 decimals places max in ETH

let ex;
before(async function() {
    this.timeout(100000);
    ex = Exchange.at(Exchange.address);
});

contract("Exchange tests", accounts => {
    it("place x buy / sell orders", async function() {
        for (let i=0; i < ITEM_COUNT; i++) {
            let price = Math.floor(Math.random() * 500) + 39000; // b/w 390 and 395 w 2 decimals
            let amount = Math.floor(Math.random() *  ONEWEI/ETHROUND ) * ETHROUND + 0.01 * ONEWEI; // b/w 0.01 & 1ETH
            let isSell = Math.random() < 0.5 ? true : false;
            if (isSell) {
                let tx = await ex.placeSellOrder(price, amount);
                testHelper.logGasUse(this, tx, "SELL order");
            } else {
                let tx = await ex.placeBuyOrder(price, amount);
                testHelper.logGasUse(this, tx, "BUY order");
            }
        }
        await exHelper.printOrderBook(10);
    });

    /* it("delete items", async function() {
        for (let i=0; i < DELETE_COUNT ; i++) {
            let pos = Math.floor( Math.random() * (ITEM_COUNT - i));
            let val = await mmh.heap(pos);
            let selectAtGas = await mmh.heap.estimateGas(pos);
            //let dupes = await ost.nodeDupes(val);
            //let dupesGas = await ost.nodeDupes.estimateGas(val);
            let tx = await mmh.deletePos(pos);
            testHelper.logGasUse(this, tx, "delete pos: " + pos + " val: " + val
                + " selectAt(" + pos + ") selectAtGas:" + selectAtGas);
        }
    }); */

    it("fill 1 order", async function() {
        let tx = await ex.fillOrder();
        testHelper.logGasUse(this, tx, "fillOrder");
        await exHelper.printOrderBook(3);
    });

    it("fill all orders", async function() {
        while (await ex.hasOrderToFill()) {
            let tx = await ex.fillOrder();
            testHelper.logGasUse(this, tx, "fillOrder");
        }
        await exHelper.printOrderBook();
    });

    it("place x small buy / + 1 big sell orders", async function() {
        let price;
        let amount;
        for (let i=0; i < ITEM_COUNT; i++) {
            price = Math.floor(Math.random() * 500) + 39000; // b/w 390 and 395 w 2 decimals
            amount = Math.floor(Math.random() *  ONEWEI/ETHROUND ) * ETHROUND + 0.01 * ONEWEI; // b/w 0.01 & 1ETH
            let tx = await ex.placeBuyOrder(price, amount);
            testHelper.logGasUse(this, tx, "BUY order");
        }
        amount = web3.toWei(2 * ITEM_COUNT, "ether");
        let tx = await ex.placeSellOrder(39000, amount);
        testHelper.logGasUse(this, tx, "SELL order");
        await exHelper.printOrderBook(10);
    });

    it("fill all orders with one big sell", async function() {
        while (await ex.hasOrderToFill()) {
            let tx = await ex.fillOrder();
            testHelper.logGasUse(this, tx, "fillOrder");
        }
        await exHelper.printOrderBook();
    });
});
