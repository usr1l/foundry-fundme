// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

// four different kinds of tests
// 1. unit tests
//      - Testing a specific part of our code
// 2. integration tests
//      - testing how our code works with other parts of our code
// 3. forked tests
//     - testing our code on a simulated real environment
// 4. staging tests
//     - testing our code on a real environment (testnet/mainnet)

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe()
        fundMe = DeployFundMe.run();
    }

    function testMinimumUsdIsFive() external view {
        uint256 minimumUsd = fundMe.MINIMUM_USD();
        assertEq(minimumUsd, 5e18);
    }

    function testOwnerIsMsgSender() external view {
        // the owner should be this contract since this contract deployed the FundMe contract
        assert(fundMe.i_owner() == msg.sender);
    }

    function testPriceFeedVersionIsAccurate() external view {
        uint256 version = fundMe.getVersion();
        assert(version == 4);
    }
}
