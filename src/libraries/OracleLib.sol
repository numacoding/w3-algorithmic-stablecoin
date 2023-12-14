// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title OracleLib
/// @author Numa
/// @notice This library is used to check the Chainlink Oracle for stale data. If a price is stale, function will revert and
/// render the DSCEngine unusable - by design.
/// We want the DSCEngine to freeze if prices become stale.
/// If the chainlink network explodes and you have a lot of money locked in the protocol... to bad

library OracleLib {
    error OracleLib__StalePrice();

    uint256 private constant TIMEOUT = 3 hours; // 3*60*60

    function staleCheckLatestRoundData(
        AggregatorV3Interface _priceFeed
    ) public view returns (uint80, int256, uint256, uint256, uint80) {
        (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = _priceFeed.latestRoundData();
        uint256 secondsSince = block.timestamp - updatedAt;

        if (secondsSince > TIMEOUT) revert OracleLib__StalePrice();

        return (roundId, answer, startedAt, updatedAt, answeredInRound);
    }
}
