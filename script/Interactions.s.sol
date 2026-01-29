// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

uint256 constant SEND_VALUE = 1e18;

contract FundFundMe is Script {
    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDepoyed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(mostRecentDepoyed);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        withdrawFundMe(mostRecentlyDeployed);
    }
}
