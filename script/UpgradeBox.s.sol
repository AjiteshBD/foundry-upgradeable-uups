//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {BoxV2} from "src/BoxV2.sol";
import {BoxV1} from "src/BoxV1.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {DevOpsTools} from "@foundry-devops/src/DevOpsTools.sol";

contract UpgradeBox is Script {
    function run() external returns (address) {
        address proxy = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);

        vm.startBroadcast();
        BoxV2 box = new BoxV2();

        vm.stopBroadcast();

        return upgrade(proxy, address(box));
    }

    function upgrade(address _proxy, address _implementation) public returns (address) {
        vm.startBroadcast();
        BoxV1 v1proxy = BoxV1(payable(_proxy));
        v1proxy.upgradeToAndCall(address(_implementation), "");
        vm.stopBroadcast();
        return address(v1proxy);
    }
}
