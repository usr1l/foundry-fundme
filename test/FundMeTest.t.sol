// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {console} from "forge-std/console.sol";
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
        // console.log("MSG.SENDER in setUp:", msg.sender); // 0x1804
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
        assert(fundMe.getOwner() == msg.sender);
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
        // the next tx will be sent by USER
        vm.prank(USER);

        // if fn is a payable fn, we can send eth like this
        // fundMe.fund{value: 1e18}();
        fundMe.fund{value: SEND_VAL}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VAL);
    }

    function testAddsFunderToArrayOfFunders() external {
        vm.prank(USER);
        fundMe.fund{value: SEND_VAL}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VAL}();
        _;
    }

    function testOnlyOwnerCanWithdraw() external funded {
        // vm.prank(msg.sender); // this will fail beacuse msg.sender is the owner
        // console.log("FundMe owner:", fundMe.getOwner());
        // console.log("User:", USER);
        // console.log("Msg.sender:", msg.sender);
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() external funded {
        // arrange
        // can always check any address balance with address(this).balance
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
        assertEq(endingFundMeBalance, 0);

    }
}
