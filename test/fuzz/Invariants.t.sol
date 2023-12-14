// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// //invariants/properties will be located here
// // 1. Total supply of DSC should be less than the total value of collateral
// // 2. Getter view functions should never revert <- evergreen invariant

// import {Test, console} from "forge-std/Test.sol";
// import {StdInvariant} from "forge-std/StdInvariant.sol";
// import {DSCEngine} from "../../src/DSCEngine.sol";
// import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
// import {DeployDSC} from "../../script/DeployDSC.s.sol";
// import {HelperConfig} from "../../script/HelperConfig.s.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import {ERC20Mock} from "../mocks/ERC20Mock.sol";

// import {Handler} from "./Handler.t.sol";

// contract Invariants is StdInvariant, Test {
//     DeployDSC deployer;
//     DecentralizedStableCoin decentralizedStableCoin;
//     DSCEngine dscEngine;
//     HelperConfig helperConfig;
//     address wbtc;
//     address weth;
//     Handler handler;

//     function setUp() external {
//         deployer = new DeployDSC();
//         (decentralizedStableCoin, dscEngine, helperConfig) = deployer.run();
//         (, , weth, wbtc, ) = helperConfig.activeNetworkConfig();

//         handler = new Handler(dscEngine, decentralizedStableCoin);
//         targetContract(address(handler));
//     }

//     function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
//         uint256 totalSupply = decentralizedStableCoin.totalSupply();
//         uint256 totalWethDeposited = ERC20Mock(weth).balanceOf(
//             address(dscEngine)
//         );
//         uint256 totalWbtcDeposited = ERC20Mock(wbtc).balanceOf(
//             address(dscEngine)
//         );

//         uint256 wethValue = dscEngine.getUsdValue(weth, totalWethDeposited);
//         uint256 wbtcValue = dscEngine.getUsdValue(wbtc, totalWbtcDeposited);

//         console.log("weth value: ", wethValue);
//         console.log("wbtc value: ", wbtcValue);
//         console.log("total supply: ", totalSupply);
//         // console.log("Times mint called: ", handler.timesMintIsCalled());

//         assert(wethValue + wbtcValue >= totalSupply);
//     }

//     function invariant_gettersShouldNotRevert() public view {
//         dscEngine.getCollateralTokens();
//     }
// }
