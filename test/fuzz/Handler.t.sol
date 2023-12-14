// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// import {Test, console} from "forge-std/Test.sol";
// import {DSCEngine} from "../../src/DSCEngine.sol";
// import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
// import {DeployDSC} from "../../script/DeployDSC.s.sol";
// import {ERC20Mock} from "../mocks/ERC20Mock.sol";
// import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";

// contract Handler is Test {
//     DSCEngine dscEngine;
//     DecentralizedStableCoin decentralizedStableCoin;

//     ERC20Mock weth;
//     ERC20Mock wbtc;

//     uint256 timesMintIsCalled;
//     uint256 constant MAX_DEPOSIT_SIZE = type(uint96).max;

//     address[] public usersWithCollateralDeposited;

//     MockV3Aggregator public ethUsdPriceFeed;

//     constructor(DSCEngine _dsce, DecentralizedStableCoin _dsc) {
//         dscEngine = _dsce;
//         decentralizedStableCoin = _dsc;
//         address[] memory collateralAddresses = dscEngine.getCollateralTokens();

//         weth = ERC20Mock(collateralAddresses[0]);
//         wbtc = ERC20Mock(collateralAddresses[1]);

//         ethUsdPriceFeed = MockV3Aggregator(
//             dscEngine.getCollateralTokenPriceFeed(address(weth))
//         );
//     }

//     //1. call redeemCollateral only when there's collateral
//     function depositCollateral(
//         uint256 _collateralSeed,
//         uint256 _amountCollateral
//     ) public {
//         // vm.startPrank(msg.sender);
//         ERC20Mock collateral = _collateralChooserFromSeed(_collateralSeed);
//         _amountCollateral = bound(_amountCollateral, 1, MAX_DEPOSIT_SIZE);

//         vm.startPrank(msg.sender);
//         collateral.mint(msg.sender, _amountCollateral);
//         collateral.approve(address(dscEngine), _amountCollateral);
//         dscEngine.depositCollateral(address(collateral), _amountCollateral);

//         // @note double push
//         usersWithCollateralDeposited.push(msg.sender);
//     }

//     //helper function for choosing the collateral
//     function _collateralChooserFromSeed(
//         uint256 _seed
//     ) private view returns (ERC20Mock) {
//         if (_seed % 2 == 0) {
//             return weth;
//         }
//         return wbtc;
//     }

//     // //2. Now that we deposit collateral, we'll work on redeem collateral
//     // function redeemCollateral(
//     //     uint256 _collateralSeed,
//     //     uint256 _amountCollateral
//     // ) public {
//     //     ERC20Mock collateral = _collateralChooserFromSeed(_collateralSeed);

//     //     uint256 maxCollateralToRedeem = dscEngine.getUserCollateralBalance(
//     //         msg.sender,
//     //         address(collateral)
//     //     );
//     //     console.log("COLLATERAL TO REDEEM: ", maxCollateralToRedeem);

//     //     _amountCollateral = bound(_amountCollateral, 1, maxCollateralToRedeem);

//     //     if (_amountCollateral == 0) {
//     //         return;
//     //     }

//     //     dscEngine.redeemCollateral(address(collateral), _amountCollateral);
//     // }

//     // function mintDsc(uint256 _amount, uint256 addressSeed) public {
//     //     if (usersWithCollateralDeposited.length == 0) {
//     //         return;
//     //     }

//     //     address sender = usersWithCollateralDeposited[
//     //         addressSeed % usersWithCollateralDeposited.length
//     //     ];

//     //     (uint256 totalDscMinted, uint256 collateralValueInUsd) = dscEngine
//     //         .getAccountInformation(sender);

//     //     int256 maxDscToMint = (int256(collateralValueInUsd) / 2) -
//     //         int256(totalDscMinted);

//     //     if (maxDscToMint <= 0) {
//     //         return;
//     //     }

//     //     _amount = bound(_amount, 0, maxDscToMint);

//     //     if (_amount == 0) {
//     //         return;
//     //     }

//     //     vm.startPrank(sender);
//     //     dscEngine.mintDsc(_amount);
//     //     vm.stopPrank();
//     //     timesMintIsCalled++;
//     // }

//     function updateCollateralPrice(uint96 _newPrice) public {
//         int256 newPriceInt = int256(uint256(_newPrice));
//         ethUsdPriceFeed.updateAnswer(newPriceInt);
//     }
// }
