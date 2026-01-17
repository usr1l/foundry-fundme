// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // everything before startBroadcast() is done off-chain, will be simulated
        HelperConfig helperConfig = new HelperConfig();
        (address ethUSDPriceFeed) = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        // creating a mock price feed allows us to use less of alchemy, which might cost money
        FundMe fundMe = new FundMe(ethUSDPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
