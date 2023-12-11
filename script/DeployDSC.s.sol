//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployDSC is Script {
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function run()
        external
        returns (DecentralizedStableCoin, DSCEngine, HelperConfig)
    {
        HelperConfig config = new HelperConfig();
        (
            address wethUsdPriceFeed,
            address wbtcUsdPriceFeed,
            address weth,
            address wbtc,
            uint256 deployerKey
        ) = config.activeNetworkConfig();

        tokenAddresses = [weth, wbtc];
        priceFeedAddresses = [wethUsdPriceFeed, wbtcUsdPriceFeed];

        vm.startBroadcast(deployerKey);
        DecentralizedStableCoin decentralizedStableCoin = new DecentralizedStableCoin();
        DSCEngine dscEngine = new DSCEngine(
            tokenAddresses,
            priceFeedAddresses,
            address(decentralizedStableCoin)
        );

        /// @notice need to transfer the ownership of the contract to the engine
        decentralizedStableCoin.transferOwnership(address(dscEngine));
        vm.stopBroadcast();

        return (decentralizedStableCoin, dscEngine, config);
    }
}
