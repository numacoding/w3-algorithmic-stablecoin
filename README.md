# Decentralized Stablecoin project

The purpose of this repository is to create an overcollateralized stablecoin with the following properties:
1. (Relative Stability) Anchored or Pegged to USD
   1. Chainlink Price Feed
   2. Set a function to exchange ETH & BTC for whatever that USD equivalent is
2. Stability Mechanism (Minting): Algorithmic (Decentralized)
   1. People can only mint the stablecoin with enough collateral (coded)
3. Collateral: Exogenous (Crypto)
   1. wETH
   2. wBTC
   
## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (8c11482 2023-11-16T00:32:37.968294000Z)`

## Roadmap
- [x] Code ERC20 contract ([`DecentralizedStableCoin.sol`](https://github.com/numacoding/w3-algorithmic-stablecoin/blob/main/src/DecentralizedStableCoin.sol))
- [ ] Code Decentralized Stablecoin Engine ([`DSCEngine.sol`](https://github.com/numacoding/w3-algorithmic-stablecoin/blob/main/src/DSCEngine.sol)). 
  - [x] deposit collateral function
  - [x] mint function
  - [ ] deposit collateral & mint function
  - [ ] redeem collateral function
  - [ ] redeem collateral for DSC function
  - [ ] burn DSC function
  - [ ] liquidate function
- [x] Deploy Script
- [x] HelperConfig Script
- [ ] Testing