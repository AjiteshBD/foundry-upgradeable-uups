//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {DeployBox} from "script/DeployBox.s.sol";
import {UpgradeBox} from "script/UpgradeBox.s.sol";
import {BoxV1} from "src/BoxV1.sol";
import {BoxV2} from "src/BoxV2.sol";

contract DeployAndTest is Test {
    DeployBox deployBox;
    UpgradeBox upgradeBox;
    address DEPLOYER = makeAddr("ADMIN");
    address proxy;
    uint256 BoxV2VERSION = 2;
    uint256 BoxV1VERSION = 1;
    uint256 VALUE = 3;

    function setUp() public {
        deployBox = new DeployBox();
        upgradeBox = new UpgradeBox();
        proxy = deployBox.run();
    }

    function testBoxV1Revert() public {
        assertEq(BoxV1(proxy).getVersion(), BoxV1VERSION); // assert box1 version
        vm.expectRevert();
        BoxV2(proxy).setValue(VALUE); // trying box2 function v1 it should revert as there is no function setValue in V1 using the ABI of V2
    }

    function testUpgradeBoxV2() public {
        BoxV2 boxV2 = new BoxV2(); //new implementation
        upgradeBox.upgrade(proxy, address(boxV2));

        assertEq(BoxV2(proxy).getVersion(), BoxV2VERSION); //assert v2 version
        BoxV2(proxy).setValue(VALUE);
        assertEq(BoxV2(proxy).getValue(), VALUE);
    }
}
