// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";

contract Handler is Test {
    DSCEngine dscEngine;
    DecentralizedStableCoin decentralizedStableCoin;

    ERC20Mock weth;
    ERC20Mock wbtc;

    uint256 constant MAX_DEPOSIT_SIZE = type(uint96).max;

    constructor(DSCEngine _dsce, DecentralizedStableCoin _dsc) {
        dscEngine = _dsce;
        decentralizedStableCoin = _dsc;
        address[] memory collateralAddresses = dscEngine.getCollateralTokens();

        weth = ERC20Mock(collateralAddresses[0]);
        wbtc = ERC20Mock(collateralAddresses[1]);
    }

    //1. call redeemCollateral only when there's collateral
    function depositCollateral(
        uint256 _collateralSeed,
        uint256 _amountCollateral
    ) public {
        // vm.startPrank(msg.sender);
        ERC20Mock collateral = _collateralChooserFromSeed(_collateralSeed);
        _amountCollateral = bound(_amountCollateral, 1, MAX_DEPOSIT_SIZE);

        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, _amountCollateral);
        collateral.approve(address(dscEngine), _amountCollateral);
        dscEngine.depositCollateral(address(collateral), _amountCollateral);
    }

    //helper function for choosing the collateral
    function _collateralChooserFromSeed(
        uint256 _seed
    ) private view returns (ERC20Mock) {
        if (_seed % 2 == 0) {
            return weth;
        }
        return wbtc;
    }
}
