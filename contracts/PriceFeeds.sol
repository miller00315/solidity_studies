// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract PriceConsumerV3 {
    AggregatorV3Interface internal priceFeed;

    /**
    *Network: Sepolia
    *Aggregator: ETH/USD
    *Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
    *More info: https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1
    */

    constructor() public {
        priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    /**
    * Returns the lates price
    */

    function getLatestPrice() public view returns  (int) {
        (
            uint80 roundId,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answerdInRound
        ) = priceFeed.latestRoundData();

        return price;
    }

    function getTimestamp() public view returns  (uint) {
        (
            uint80 roundId,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answerdInRound
        ) = priceFeed.latestRoundData();

        return timeStamp;
    }
}