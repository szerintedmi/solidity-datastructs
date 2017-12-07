/*
TODO: add market order (maybe just store with 0 price?)
TODO: implement an order queue. i.e. placing an order just would save it in a "queue"
        and ordermatching could deal with it along the orders already in the orderbook
TODO: create a new func which takes an order and makes as many fills as possible in the same tx?
TODO: make deleteBuy/SellOrder safe, e.g. introduce an orderId and pass along with pos or just pass timestamp?
TODO: placeSell/BuyOrderAndFill funcs which could fill up as much from the book as possible with provided gas?
TODO: takeSellOrder/takeBuyOrder(price, amount) to directly take a specific order from the top of the orderbook ?
*/
pragma solidity ^0.4.18;


import "./OrderHeap.sol";


contract Exchange {
    OrderHeap.Order[] public sellOrders; // price stored as minus to have lowest
                                        // price on top of the heap
    OrderHeap.Order[] public buyOrders;
    using OrderHeap for OrderHeap.Order[];

    function getSellOrderCount() external view returns(uint ct) {
        return sellOrders.length;
    }

    function getBuyOrderCount() external view returns(uint ct) {
        return buyOrders.length;
    }

    function placeSellOrder(int price, uint amount) public {
        OrderHeap.Order memory order = OrderHeap.Order(msg.sender, -price, uint32(now), amount);
        sellOrders.insert(order);
    }

    function deleteSellOrder(uint pos) public {
        require(msg.sender == sellOrders[pos].owner);
        sellOrders.deletePos(pos);
    }

    function placeBuyOrder(int price, uint amount) public {
        OrderHeap.Order memory order = OrderHeap.Order(msg.sender, price, uint32(now), amount);
        buyOrders.insert(order);
    }

    function deleteBuyOrder(uint pos) public {
        require(msg.sender == buyOrders[pos].owner);
        buyOrders.deletePos(pos);
    }

    function hasOrderToFill() public view returns(bool _hasOrderToFill) {
        return (buyOrders.length > 0 && sellOrders.length > 0
                && buyOrders[0].price >= -sellOrders[0].price);
    }

    event OrderFill(address buyer, address seller, uint128 price, uint amount, uint amountValue);

    function fillOrder() public {
        if (hasOrderToFill()) {
            address buyer = buyOrders[0].owner;
            address seller = sellOrders[0].owner;
            // TODO: change this to prefer the price which is closer to ACD/USD par
            uint128 price;
            if (buyOrders[0].time > sellOrders[0].time) {
                price = uint128(buyOrders[0].price); // taker is the buyer

            } else {
                price = uint128(-sellOrders[0].price); // taker is the seller
            }
            uint amount;
            if (buyOrders[0].amount <= sellOrders[0].amount) {
                amount = buyOrders[0].amount;
                buyOrders.deletePos(0); // fully filled buy order
                if (amount == sellOrders[0].amount) {
                    sellOrders.deletePos(0); // fully filled sell order too
                } else {
                    sellOrders[0].amount -= amount; // partially filled sell order
                }
            } else {
                // partially filled buy order
                amount = sellOrders[0].amount;
                buyOrders[0].amount -= amount;
                sellOrders.deletePos(0);
            }
            uint amountValue = amount * price;

            OrderFill(buyer, seller, price, amount, amountValue);
        }
    }

}
