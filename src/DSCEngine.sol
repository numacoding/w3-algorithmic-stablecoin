//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title DSCEngine
/// @author Numa
/// @notice System designed to be as minimal as possible, and have the token maintain a 1 token == $1 peg
/// Stablecoin properties:
/// 1. (Relative Stability) Anchored or Pegged to USD
/// 2. Stability Mechanism (Minting): Algorithmic (Decentralized)
/// 3. Collateral: Exogenous (Crypto). MUST be always overcollateralized using:
///    1. wETH
///    2. wBTC
/// Similar to DAI but without governance, fees, and if it was only backed by wETH & wBTC.
/// This contract is the core of the DSC system. It handles all the logic for minting and redeeming DSC, as well as depositing
/// and withdrawing collateral.
/// @dev Use of Chainlink Price Feed for peg

contract DSCEngine is ReentrancyGuard {
    ////////////////////////////////
    //          errors
    ////////////////////////////////
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenAddressedAndPriceFeedAddressesMustMatchLength();
    error DSCEngine__NotAllowedToken();
    error DSCEngine__TransferFailed();
    error DSCEngine__BreaksHealthFactor(uint256 healthFacror);
    error DSCEngine__MintFailed();

    ////////////////////////////////
    //         State Variables
    ////////////////////////////////
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50; // your collateral needs to double the value of the minted stablecoins
    uint256 private constant MIN_HEALTH_FACTOR = 1;

    mapping(address token => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount))
        private s_collateralDeposited;
    mapping(address user => uint256 amountDscMinted) private s_DSCMinted;
    address[] private s_collateralTokens;

    DecentralizedStableCoin private immutable i_sdc;

    ////////////////////////////////
    //         events
    ////////////////////////////////

    event CollateralDeposited(
        address indexed user,
        address indexed token,
        uint256 indexed amount
    );

    ////////////////////////////////
    //         modifiers
    ////////////////////////////////

    modifier moreThanZero(uint256 _amount) {
        if (_amount == 0) {
            revert DSCEngine__NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address _token) {
        if (s_priceFeeds[_token] == address(0)) {
            revert DSCEngine__NotAllowedToken();
        }
        _;
    }

    ////////////////////////////////
    //          functions
    ////////////////////////////////
    constructor(
        address[] memory _tokenAddresses,
        address[] memory _priceFeedAddress,
        address _dscAddress
    ) {
        if (_tokenAddresses.length != _priceFeedAddress.length) {
            revert DSCEngine__TokenAddressedAndPriceFeedAddressesMustMatchLength();
        }

        /// @notice here we are matching the address of the token with its USD price (BTC/USD, ETH/USD)
        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            s_priceFeeds[_tokenAddresses[i]] = _priceFeedAddress[i];
            /// @notice pushing the token addresses to this array will allow us to loop through it and calculate how much value users have based on the
            /// tokens they provide as collateral.
            s_collateralTokens.push(_tokenAddresses[i]);
        }

        i_sdc = DecentralizedStableCoin(_dscAddress);
    }

    /////////////////////////////////
    //      external functions
    ////////////////////////////////

    /// @param _tokenCollateralAddress the address of the token to deposit as collateral
    /// @param _amountCollateral the amount of collateral to deposit
    function depositCollateral(
        address _tokenCollateralAddress,
        uint256 _amountCollateral
    )
        external
        moreThanZero(_amountCollateral)
        isAllowedToken(_tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[_tokenCollateralAddress][
            msg.sender
        ] += _amountCollateral;

        emit CollateralDeposited(
            msg.sender,
            _tokenCollateralAddress,
            _amountCollateral
        );

        bool success = IERC20(_tokenCollateralAddress).transferFrom(
            msg.sender,
            address(this),
            _amountCollateral
        );

        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function depositCollateralAndMintDsc() external {}

    function redeemCollateral() external {}

    function redeemCollateralForDsc() external {}

    /// @notice a user will be able to mint a quantity proportional to the min threshold of the collateral
    /// @param _amountDscToMint amount of DSC to mint
    // check if the collateral value > DSC amount
    function mintDsc(
        uint256 _amountDscToMint
    ) external moreThanZero(_amountDscToMint) {
        s_DSCMinted[msg.sender] += _amountDscToMint;
        _revertIfHealthFactorIsBroken(msg.sender);

        bool minted = i_sdc.mint(msg.sender, _amountDscToMint);

        if (!minted) {
            revert DSCEngine__MintFailed();
        }
    }

    function burnDsc() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}

    /////////////////////////////////
    //  Private & Internal Functions
    /////////////////////////////////

    function _getAccountInformation(
        address _user
    )
        private
        view
        returns (uint256 totalDscMinted, uint256 collateralValueInUsd)
    {
        totalDscMinted = s_DSCMinted[_user];
        collateralValueInUsd = getAccountCollateralValue(_user);
    }

    /// @notice Returns how close to liquidation a user is. If goes below 1, then they can get liquidated
    function _healthFactor(address _user) private view returns (uint256) {
        //total dsc minted
        //total collateral value
        (
            uint256 totalDscMinted,
            uint256 collateralValueInUsd
        ) = _getAccountInformation(_user);

        uint256 collateralAdjustedForThreshold = (collateralValueInUsd *
            LIQUIDATION_THRESHOLD) / 100;

        return (collateralAdjustedForThreshold * PRECISION) / totalDscMinted;
    }

    // 1. check health factor
    // 2. revert if it don't
    function _revertIfHealthFactorIsBroken(address _user) internal view {
        uint256 userHealthFactor = _healthFactor(_user);
        if (userHealthFactor < MIN_HEALTH_FACTOR) {
            revert DSCEngine__BreaksHealthFactor(userHealthFactor);
        }
    }

    /////////////////////////////////
    //  Public & External View Functions
    /////////////////////////////////

    function getAccountCollateralValue(
        address _user
    ) public view returns (uint256 _totalCollateralValueInUsd) {
        //loop through each collateral token, get the amount they have deposited, and map it to the price to get the USD value.
        for (uint256 i = 0; i < s_collateralTokens.length; i++) {
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposited[_user][token];
            _totalCollateralValueInUsd += getUsdValue(token, amount);
        }

        return _totalCollateralValueInUsd;
    }

    function getUsdValue(
        address _token,
        uint256 _amount
    ) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            s_priceFeeds[_token]
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        /// @notice if 1 ETH = 1000 USD, the returned value from CL will be 1000 * 1e8
        return
            ((uint256(price) * ADDITIONAL_FEED_PRECISION) * _amount) /
            PRECISION;
    }
}
