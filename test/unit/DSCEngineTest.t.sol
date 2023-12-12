//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";

contract DSCEngineTest is Test {
    DeployDSC deployer;
    DecentralizedStableCoin decentralizedStableCoin;
    DSCEngine dscEngine;
    HelperConfig helperConfig;
    address ethUsdPriceFeed;
    address btcUsdPriceFeed;
    address weth;

    address USER = makeAddr("user");
    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    uint256 public constant STARTING_ERC20_BALANCE = 10 ether;

    function setUp() public {
        deployer = new DeployDSC();
        (decentralizedStableCoin, dscEngine, helperConfig) = deployer.run();
        (ethUsdPriceFeed, btcUsdPriceFeed, weth, , ) = helperConfig
            .activeNetworkConfig();

        ERC20Mock(weth).mint(USER, STARTING_ERC20_BALANCE);
    }

    ////////////////////////
    // Constructor Tests
    ////////////////////////

    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function testRevertsIfTokenLengthDoesntMatchPriceFeeds() public {
        tokenAddresses.push(weth);
        priceFeedAddresses.push(ethUsdPriceFeed);
        priceFeedAddresses.push(btcUsdPriceFeed);

        vm.expectRevert(
            DSCEngine
                .DSCEngine__TokenAddressedAndPriceFeedAddressesMustMatchLength
                .selector
        );
        new DSCEngine(
            tokenAddresses,
            priceFeedAddresses,
            address(decentralizedStableCoin)
        );
    }

    ////////////////////////
    //  Price Tests
    ////////////////////////
    function testGetUsdValue() public {
        uint256 ethAmount = 15e18;
        uint256 expectedUsd = 30000e18; //15e19 * 2000/ETH
        uint256 actualUsd = dscEngine.getUsdValue(weth, ethAmount);
        console.log("actual USD value", actualUsd);
        assertEq(expectedUsd, actualUsd);
    }

    function testGetTokenAmountFromUsd() public {
        uint256 usdAmount = 100 ether;
        uint256 expectedWeth = 0.05 ether;
        uint256 actualWeth = dscEngine.getTokenAmountFromUsd(weth, usdAmount);
        assertEq(expectedWeth, actualWeth);
    }

    /* depositCollateral */
    function testRevertsIfCollateralZero() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(dscEngine), AMOUNT_COLLATERAL);

        vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        dscEngine.depositCollateral(weth, 0);
        vm.stopPrank();
    }

    function testRevertsWithUnapprovedCollateral() public {
        ERC20Mock randomToken = new ERC20Mock(
            "Random",
            "RAN",
            USER,
            STARTING_ERC20_BALANCE
        );
        vm.startPrank(USER);
        vm.expectRevert(DSCEngine.DSCEngine__NotAllowedToken.selector);
        dscEngine.depositCollateral(
            address(randomToken),
            STARTING_ERC20_BALANCE
        );
        vm.stopPrank();
    }

    //@audit check this
    // modifier depositedCollateral() {
    //     vm.startPrank(USER);
    //     ERC20Mock(weth).approve(address(dscEngine), AMOUNT_COLLATERAL);
    //     dscEngine.depositCollateral(weth, AMOUNT_COLLATERAL);
    //     vm.stopPrank();
    //     _;
    // }

    // function testCanDepositCollateralAndGetAccountInfo()
    //     public
    //     depositedCollateral
    // {
    //     (uint256 totalDscMinted, uint256 collateralValueInUsd) = dscEngine
    //         .getAccountInformation(USER);

    //     uint256 expectedTotalDscMinted = 0;
    //     uint256 expectedCollateralValueInUsd = dscEngine.getTokenAmountFromUsd(
    //         weth,
    //         collateralValueInUsd
    //     );

    //     assertEq(totalDscMinted, expectedTotalDscMinted);
    //     assertEq(AMOUNT_COLLATERAL, expectedCollateralValueInUsd);
    // }
}
