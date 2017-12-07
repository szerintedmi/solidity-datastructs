
const Exchange = artifacts.require("./Exchange.sol");
const moment = require("moment");
const ex = Exchange.at(Exchange.address);
module.exports = {
    printOrderBook,
    getSellOrder,
    getBuyOrder
};


async function printOrderBook(limit) {

    let sellCt = await ex.getSellOrderCount();
    let buyCt = await ex.getBuyOrderCount();
    if (typeof limit == 'undefined') {
        limit = sellCt > buyCt ? sellCt : buyCt;
        limitText = "(all orders)";
    } else {
        limitText = "(top " + limit + " orders)";
    }
    console.log("========= Order Book " + limitText + " =========");
    console.log("  Buy ct: " + buyCt + "    Sell ct: " + sellCt);

    for (let i =0; i < buyCt && i < limit; i++) {
        let order = await getBuyOrder(i)
        console.log("BUY: " + order.price  + " " + web3.fromWei(order.amount)) + " ETH "
            + moment.unix(order.time).format("HH:mm:ss");
    }

    for (let i =0; i < sellCt && i < limit; i++) {
        let order = await getSellOrder(i);
        console.log("        SELL: " + order.price  + " " + web3.fromWei(order.amount)) + " ETH "
            + moment.unix(order.time).format("HH:mm:ss");
    }

    console.log("=========/Order Book =========");
}

async function getSellOrder(i) {
    return parseOrder(await ex.sellOrders(i))
}

async function getBuyOrder(i) {
    return parseOrder(await ex.buyOrders(i))
}

function parseOrder(order) {
    return {
        owner: order[0],
        price: order[1],
        time: order[2],
        amount: order[3]
    }
}
