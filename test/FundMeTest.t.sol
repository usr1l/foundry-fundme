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

    address USER = makeAddr("user");
    uint256 constant SEND_VAL = 0.1 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 20e18);
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

    function testFundFailsWithoutEnoughEth() external {
        vm.expectRevert(); // expect the next line to revert
        fundMe.fund{value: 1e10}();
    }

    function testFundUpdatesFundedDataStructure() external {
        // if fn is a payable fn, we can send eth like this
        // fundMe.fund{value: 1e18}();
        vm.prank(USER);
        fundMe.fund{value: SEND_VAL}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VAL);
    }
}
